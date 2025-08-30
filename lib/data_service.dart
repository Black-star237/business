import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DataService {
  final supabase = Supabase.instance.client;

  // Récupérer les KPIs pour une période donnée
  Future<Map<String, dynamic>> getKpis({
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
    required String previousStartDate,
    required String previousEndDate,
  }) async {
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
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String())
          .single();

      final previousOrdersResponse = await supabase
          .from('sales')
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .gte('sale_date', previousStartDate)
          .lte('sale_date', previousEndDate)
          .single();

      // Clients actifs
      final activeClientsResponse = await supabase
          .from('clients')
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .eq('is_active', true)
          .single();

      final previousActiveClientsResponse = await supabase
          .from('clients')
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .eq('is_active', true)
          .gte('created_at', previousStartDate)
          .lte('created_at', previousEndDate)
          .single();

      // Alertes de stock
      final stockAlertsResponse = await supabase
          .from('inventory_alerts')
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .eq('is_resolved', false)
          .single();

      final previousStockAlertsResponse = await supabase
          .from('inventory_alerts')
          .select('count', count: 'exact')
          .eq('company_id', companyId)
          .eq('is_resolved', false)
          .gte('created_at', previousStartDate)
          .lte('created_at', previousEndDate)
          .single();

      return {
        'revenue': {
          'current': revenueResponse['revenue'] ?? 0,
          'previous': previousRevenueResponse['revenue'] ?? 0,
        },
        'orders': {
          'current': ordersResponse['count'] ?? 0,
          'previous': previousOrdersResponse['count'] ?? 0,
        },
        'activeClients': {
          'current': activeClientsResponse['count'] ?? 0,
          'previous': previousActiveClientsResponse['count'] ?? 0,
        },
        'stockAlerts': {
          'current': stockAlertsResponse['count'] ?? 0,
          'previous': previousStockAlertsResponse['count'] ?? 0,
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

  // Récupérer les activités récentes
  Future<List<Map<String, dynamic>>> getRecentActivities({
    required String companyId,
    int limit = 10,
  }) async {
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
    final formatter = NumberFormat('#,##0', 'fr_FR');
    final difference = current - previous;
    final percentageChange = previous != 0 ? (difference / previous) * 100 : 0;

    final comparisonText = difference >= 0
        ? '+${formatter.format(difference)} (${percentageChange.toStringAsFixed(1)}%)'
        : '${formatter.format(difference)} (${percentageChange.toStringAsFixed(1)}%)';

    return '${formatter.format(current)}\n$comparisonText';
  }
}