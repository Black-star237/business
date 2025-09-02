import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kpi_service.dart';
import 'main_revenue_card.dart';
import 'secondary_kpi_card.dart';

class KpiDashboard extends StatelessWidget {
  final String companyId;
  final bool isDarkMode;

  const KpiDashboard({
    required this.companyId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadKpiData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};

        return Column(
          children: [
            MainRevenueCard(
              revenue: data['revenue'] != null
                  ? '${data['revenue']['current']} €'
                  : '0 FCFA',
              comparison: data['revenue'] != null
                  ? _formatComparison(
                      data['revenue']['current'],
                      data['revenue']['previous'],
                    )
                  : '0%',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SecondaryKpiCard(
                    title: 'Commandes',
                    value: data['orders'] != null
                        ? data['orders']['current'].toString()
                        : '0',
                    comparison: data['orders'] != null
                        ? _formatComparison(
                            data['orders']['current'],
                            data['orders']['previous'],
                          )
                        : '0%',
                    icon: Icons.shopping_cart,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 16),
                  SecondaryKpiCard(
                    title: 'Clients Actifs',
                    value: data['activeClients'] != null
                        ? data['activeClients']['current'].toString()
                        : '0',
                    comparison: data['activeClients'] != null
                        ? _formatComparison(
                            data['activeClients']['current'],
                            data['activeClients']['previous'],
                          )
                        : '0%',
                    icon: Icons.people,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 16),
                  SecondaryKpiCard(
                    title: 'Alertes de Stock',
                    value: data['stockAlerts'] != null
                        ? data['stockAlerts']['current'].toString()
                        : '0',
                    comparison: data['stockAlerts'] != null
                        ? _formatComparison(
                            data['stockAlerts']['current'],
                            data['stockAlerts']['previous'],
                          )
                        : '0%',
                    icon: Icons.warning,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadKpiData() async {
    final kpiService = KpiService();

    // Calculer les périodes
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1); // Début du mois
    final endDate = DateTime(now.year, now.month + 1, 0); // Fin du mois

    // Période précédente pour comparaison
    final previousStartDate = DateTime(now.year, now.month - 1, 1);
    final previousEndDate = DateTime(now.year, now.month, 0);

    // Récupérer les données
    return await kpiService.getKpiData(
      companyId: companyId,
      startDate: startDate,
      endDate: endDate,
      previousStartDate: previousStartDate.toIso8601String(),
      previousEndDate: previousEndDate.toIso8601String(),
    );
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
}