import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_service.dart';
import 'main_revenue_card.dart';
import 'secondary_kpi_card.dart';
import 'cache_service.dart';
import 'optimized_loading_indicator.dart';

class LazyKpiDashboard extends StatefulWidget {
  final String companyId;
  final bool isDarkMode;

  const LazyKpiDashboard({
    super.key,
    required this.companyId,
    required this.isDarkMode,
  });

  @override
  State<LazyKpiDashboard> createState() => _LazyKpiDashboardState();
}

class _LazyKpiDashboardState extends State<LazyKpiDashboard> {
  final DataService _dataService = DataService();
  
  // États de chargement séparés pour chaque KPI
  bool _revenueLoaded = false;
  bool _ordersLoaded = false;
  bool _clientsLoaded = false;
  bool _stockAlertsLoaded = false;
  
  // Données des KPIs
  Map<String, dynamic> _revenueData = {'current': 0, 'previous': 0};
  Map<String, dynamic> _ordersData = {'current': 0, 'previous': 0};
  Map<String, dynamic> _clientsData = {'current': 0, 'previous': 0};
  Map<String, dynamic> _stockAlertsData = {'current': 0, 'previous': 0};

  @override
  void initState() {
    super.initState();
    _loadKpisProgressively();
  }

  Future<void> _loadKpisProgressively() async {
    // Charger d'abord depuis le cache si disponible
    final cachedData = CacheService.instance.getCachedKpis(widget.companyId);
    if (cachedData != null) {
      _updateAllKpis(cachedData);
      return;
    }

    // Sinon, charger progressivement
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    final previousStartDate = DateTime(now.year, now.month - 1, 1);
    final previousEndDate = DateTime(now.year, now.month, 0);

    // Charger le chiffre d'affaires en premier (plus important)
    _loadRevenue(startDate, endDate, previousStartDate, previousEndDate);
    
    // Puis les autres KPIs avec un délai pour éviter la surcharge
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadOrders(startDate, endDate, previousStartDate, previousEndDate);
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _loadClients(startDate, endDate, previousStartDate, previousEndDate);
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadStockAlerts(startDate, endDate, previousStartDate, previousEndDate);
    });
  }

  void _updateAllKpis(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        _revenueData = data['revenue'] ?? {'current': 0, 'previous': 0};
        _ordersData = data['orders'] ?? {'current': 0, 'previous': 0};
        _clientsData = data['activeClients'] ?? {'current': 0, 'previous': 0};
        _stockAlertsData = data['stockAlerts'] ?? {'current': 0, 'previous': 0};
        
        _revenueLoaded = true;
        _ordersLoaded = true;
        _clientsLoaded = true;
        _stockAlertsLoaded = true;
      });
    }
  }

  Future<void> _loadRevenue(DateTime startDate, DateTime endDate, 
      DateTime previousStartDate, DateTime previousEndDate) async {
    try {
      final response = await Supabase.instance.client
          .from('sales')
          .select('sum(total_amount) as revenue')
          .eq('company_id', widget.companyId)
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String())
          .single();

      final previousResponse = await Supabase.instance.client
          .from('sales')
          .select('sum(total_amount) as revenue')
          .eq('company_id', widget.companyId)
          .gte('sale_date', previousStartDate.toIso8601String())
          .lte('sale_date', previousEndDate.toIso8601String())
          .single();

      if (mounted) {
        setState(() {
          _revenueData = {
            'current': response['revenue'] ?? 0,
            'previous': previousResponse['revenue'] ?? 0,
          };
          _revenueLoaded = true;
        });
      }
    } catch (e) {
      print('Erreur chargement revenue: $e');
      if (mounted) {
        setState(() {
          _revenueLoaded = true;
        });
      }
    }
  }

  Future<void> _loadOrders(DateTime startDate, DateTime endDate, 
      DateTime previousStartDate, DateTime previousEndDate) async {
    try {
      final response = await Supabase.instance.client
          .from('sales')
          .select()
          .eq('company_id', widget.companyId)
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String())
          .count(CountOption.exact);

      final previousResponse = await Supabase.instance.client
          .from('sales')
          .select()
          .eq('company_id', widget.companyId)
          .gte('sale_date', previousStartDate.toIso8601String())
          .lte('sale_date', previousEndDate.toIso8601String())
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
          _ordersData = {
            'current': response.count ?? 0,
            'previous': previousResponse.count ?? 0,
          };
          _ordersLoaded = true;
        });
      }
    } catch (e) {
      print('Erreur chargement orders: $e');
      if (mounted) {
        setState(() {
          _ordersLoaded = true;
        });
      }
    }
  }

  Future<void> _loadClients(DateTime startDate, DateTime endDate, 
      DateTime previousStartDate, DateTime previousEndDate) async {
    try {
      final response = await Supabase.instance.client
          .from('clients')
          .select()
          .eq('company_id', widget.companyId)
          .eq('is_active', true)
          .count(CountOption.exact);

      final previousResponse = await Supabase.instance.client
          .from('clients')
          .select()
          .eq('company_id', widget.companyId)
          .eq('is_active', true)
          .gte('created_at', previousStartDate.toIso8601String())
          .lte('created_at', previousEndDate.toIso8601String())
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
          _clientsData = {
            'current': response.count ?? 0,
            'previous': previousResponse.count ?? 0,
          };
          _clientsLoaded = true;
        });
      }
    } catch (e) {
      print('Erreur chargement clients: $e');
      if (mounted) {
        setState(() {
          _clientsLoaded = true;
        });
      }
    }
  }

  Future<void> _loadStockAlerts(DateTime startDate, DateTime endDate, 
      DateTime previousStartDate, DateTime previousEndDate) async {
    try {
      final response = await Supabase.instance.client
          .from('inventory_alerts')
          .select()
          .eq('company_id', widget.companyId)
          .eq('is_resolved', false)
          .count(CountOption.exact);

      final previousResponse = await Supabase.instance.client
          .from('inventory_alerts')
          .select()
          .eq('company_id', widget.companyId)
          .eq('is_resolved', false)
          .gte('created_at', previousStartDate.toIso8601String())
          .lte('created_at', previousEndDate.toIso8601String())
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
          _stockAlertsData = {
            'current': response.count ?? 0,
            'previous': previousResponse.count ?? 0,
          };
          _stockAlertsLoaded = true;
        });
      }

      // Mettre en cache toutes les données une fois chargées
      if (_revenueLoaded && _ordersLoaded && _clientsLoaded && _stockAlertsLoaded) {
        CacheService.instance.cacheKpis(widget.companyId, {
          'revenue': _revenueData,
          'orders': _ordersData,
          'activeClients': _clientsData,
          'stockAlerts': _stockAlertsData,
        });
      }
    } catch (e) {
      print('Erreur chargement stock alerts: $e');
      if (mounted) {
        setState(() {
          _stockAlertsLoaded = true;
        });
      }
    }
  }

  String _formatComparison(dynamic current, dynamic previous) {
    if (current == null || previous == null) return '0%';

    final difference = (current - previous).toDouble();
    final percentage = previous != 0 ? (difference / previous) * 100 : 0;

    if (difference > 0) {
      return '+${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else if (difference < 0) {
      return '${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else {
      return '0%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chiffre d'affaires principal
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _revenueLoaded
              ? MainRevenueCard(
                  key: const ValueKey('revenue_loaded'),
                  revenue: '${_revenueData['current']} FCFA',
                  comparison: _formatComparison(
                    _revenueData['current'],
                    _revenueData['previous'],
                  ),
                  isDarkMode: widget.isDarkMode,
                )
              : Container(
                  key: const ValueKey('revenue_loading'),
                  height: 120,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SimpleLoadingSpinner(size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Chargement du chiffre d\'affaires...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        
        // KPIs secondaires
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Commandes
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _ordersLoaded
                    ? SecondaryKpiCard(
                        key: const ValueKey('orders_loaded'),
                        title: 'Commandes',
                        value: _ordersData['current'].toString(),
                        comparison: _formatComparison(
                          _ordersData['current'],
                          _ordersData['previous'],
                        ),
                        icon: Icons.shopping_cart,
                        isDarkMode: widget.isDarkMode,
                      )
                    : const KpiLoadingCard(
                        key: ValueKey('orders_loading'),
                        title: 'Chargement commandes...',
                      ),
              ),
              const SizedBox(width: 16),
              
              // Clients actifs
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _clientsLoaded
                    ? SecondaryKpiCard(
                        key: const ValueKey('clients_loaded'),
                        title: 'Clients Actifs',
                        value: _clientsData['current'].toString(),
                        comparison: _formatComparison(
                          _clientsData['current'],
                          _clientsData['previous'],
                        ),
                        icon: Icons.people,
                        isDarkMode: widget.isDarkMode,
                      )
                    : const KpiLoadingCard(
                        key: ValueKey('clients_loading'),
                        title: 'Chargement clients...',
                      ),
              ),
              const SizedBox(width: 16),
              
              // Alertes de stock
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _stockAlertsLoaded
                    ? SecondaryKpiCard(
                        key: const ValueKey('stock_loaded'),
                        title: 'Alertes de Stock',
                        value: _stockAlertsData['current'].toString(),
                        comparison: _formatComparison(
                          _stockAlertsData['current'],
                          _stockAlertsData['previous'],
                        ),
                        icon: Icons.warning,
                        isDarkMode: widget.isDarkMode,
                      )
                    : const KpiLoadingCard(
                        key: ValueKey('stock_loading'),
                        title: 'Chargement alertes...',
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}