import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'cache_service.dart';

class DataService with CacheMixin {
  final supabase = Supabase.instance.client;

  // Récupérer les KPIs pour une période donnée avec cache
  Future<Map<String, dynamic>> getKpis({
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
    required String previousStartDate,
    required String previousEndDate,
  }) async {
    final cacheKey = 'kpis_${companyId}_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
    
    return withCache(
      cacheKey,
      () => _fetchKpisFromDatabase(companyId, startDate, endDate, previousStartDate, previousEndDate),
      ttl: const Duration(minutes: 2), // Cache court pour les KPIs
    );
  }
  
  Future<Map<String, dynamic>> _fetchKpisFromDatabase(
    String companyId,
    DateTime startDate,
    DateTime endDate,
    String previousStartDate,
    String previousEndDate,
  ) async {
    try {
      // Chiffre d'affaires
      final revenueResponse = await supabase
          .from('sales')
          .select('sum(total_amount) as revenue')
          .eq('company_id', companyId)
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String())
          .single();

      final previousRevenueResponse = await supabase
          .from('sales')
          .select('sum(total_amount) as revenue')
          .eq('company_id', companyId)
          .gte('sale_date', previousStartDate)
          .lte('sale_date', previousEndDate)
          .single();

      // Commandes
      final ordersResponse = await supabase
          .from('sales')
          .select()
          .eq('company_id', companyId)
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String())
          .count(CountOption.exact);

      final previousOrdersResponse = await supabase
          .from('sales')
          .select()
          .eq('company_id', companyId)
          .gte('sale_date', previousStartDate)
          .lte('sale_date', previousEndDate)
          .count(CountOption.exact);

      // Clients actifs
      final activeClientsResponse = await supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .eq('is_active', true)
          .count(CountOption.exact);

      final previousActiveClientsResponse = await supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .eq('is_active', true)
          .gte('created_at', previousStartDate)
          .lte('created_at', previousEndDate)
          .count(CountOption.exact);

      // Alertes de stock
      final stockAlertsResponse = await supabase
          .from('inventory_alerts')
          .select()
          .eq('company_id', companyId)
          .eq('is_resolved', false)
          .count(CountOption.exact);

      final previousStockAlertsResponse = await supabase
          .from('inventory_alerts')
          .select()
          .eq('company_id', companyId)
          .eq('is_resolved', false)
          .gte('created_at', previousStartDate)
          .lte('created_at', previousEndDate)
          .count(CountOption.exact);

      return {
        'revenue': {
          'current': revenueResponse['revenue'] ?? 0,
          'previous': previousRevenueResponse['revenue'] ?? 0,
        },
        'orders': {
          'current': ordersResponse.count ?? 0,
          'previous': previousOrdersResponse.count ?? 0,
        },
        'activeClients': {
          'current': activeClientsResponse.count ?? 0,
          'previous': previousActiveClientsResponse.count ?? 0,
        },
        'stockAlerts': {
          'current': stockAlertsResponse.count ?? 0,
          'previous': previousStockAlertsResponse.count ?? 0,
        },
      };
    } catch (error) {
      print('Error fetching KPIs: $error');
      return {
        'revenue': {'current': 0, 'previous': 0},
        'orders': {'current': 0, 'previous': 0},
        'activeClients': {'current': 0, 'previous': 0},
        'stockAlerts': {'current': 0, 'previous': 0},
      };
    }
  }

  // Récupérer les activités récentes avec cache
  Future<List<Map<String, dynamic>>> getRecentActivities({
    required String companyId,
    int limit = 10,
  }) async {
    return withCache(
      'activities_${companyId}_$limit',
      () => _fetchRecentActivitiesFromDatabase(companyId, limit),
      ttl: const Duration(minutes: 1), // Cache très court pour les activités
    );
  }
  
  Future<List<Map<String, dynamic>>> _fetchRecentActivitiesFromDatabase(
    String companyId,
    int limit,
  ) async {
    try {
      // Combiner différentes sources d'activités
      final salesResponse = await supabase
          .from('sales')
          .select('''
            id,
            sale_number,
            total_amount,
            sale_date,
            status,
            sold_by!inner (first_name, last_name)
          ''')
          .eq('company_id', companyId)
          .order('sale_date', ascending: false)
          .limit(limit);

      final clientsResponse = await supabase
          .from('clients')
          .select('''
            id,
            name,
            created_at,
            created_by!inner (first_name, last_name)
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .limit(limit);

      final stockMovementsResponse = await supabase
          .from('stock_movements')
          .select('''
            id,
            product_id!inner (name),
            movement_type,
            quantity,
            created_at,
            created_by!inner (first_name, last_name)
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Combiner et trier toutes les activités par date
      final allActivities = [
        ...salesResponse.map((sale) => {
          'type': 'sale',
          'title': 'Nouvelle commande',
          'subtitle': 'Commande #${sale['sale_number']}',
          'amount': sale['total_amount'],
          'timestamp': sale['sale_date'],
          'user': '${sale['sold_by']['first_name']} ${sale['sold_by']['last_name']}',
        }),
        ...clientsResponse.map((client) => {
          'type': 'client',
          'title': 'Nouveau client',
          'subtitle': client['name'],
          'timestamp': client['created_at'],
          'user': '${client['created_by']['first_name']} ${client['created_by']['last_name']}',
        }),
        ...stockMovementsResponse.map((movement) => {
          'type': 'stock',
          'title': 'Mise à jour de stock',
          'subtitle': '${movement['product_id']['name']} (${movement['quantity']} ${movement['movement_type']})',
          'timestamp': movement['created_at'],
          'user': '${movement['created_by']['first_name']} ${movement['created_by']['last_name']}',
        }),
      ];

      // Trier par date (la plus récente en premier)
      allActivities.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

      return allActivities.take(limit).toList();
    } catch (error) {
      print('Error fetching recent activities: $error');
      return [];
    }
  }

  // Formater les valeurs KPI avec comparaison
  String formatKpiValue(double current, double previous) {
    final formatter = intl.NumberFormat('#,##0', 'fr_FR');
    final difference = current - previous;
    final percentageChange = previous != 0 ? (difference / previous) * 100 : 0;

    final comparisonText = difference >= 0
        ? '+${percentageChange.toStringAsFixed(1)}%'
        : '${percentageChange.toStringAsFixed(1)}%';

    return '${formatter.format(current)}\n$comparisonText';
  }
  // Récupérer une image de fond depuis app_assets par ID avec cache
  Future<String?> getBackgroundImageUrl(int assetId) async {
    return withCache(
      'bg_image_$assetId',
      () async {
        try {
          final response = await supabase
              .from('app_assets')
              .select('image_url')
              .eq('id', assetId);

          if (response.isNotEmpty) {
            return response[0]['image_url'] as String?;
          } else {
            print('No background image found for ID: $assetId');
            return null;
          }
        } catch (error) {
          print('Error fetching background image: $error');
          return null;
        }
      },
      ttl: const Duration(hours: 1), // Cache les images plus longtemps
    );
  }
}