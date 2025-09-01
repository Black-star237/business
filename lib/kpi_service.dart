import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_service.dart';

class KpiService {
  final DataService _dataService = DataService();

  Future<Map<String, dynamic>> getKpiData({
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
    required String previousStartDate,
    required String previousEndDate,
  }) async {
    return await _dataService.getKpis(
      companyId: companyId,
      startDate: startDate,
      endDate: endDate,
      previousStartDate: previousStartDate,
      previousEndDate: previousEndDate,
    );
  }

  String formatComparison(dynamic current, dynamic previous) {
    if (current == null || previous == null) return '0%';

    final difference = (current - previous).toDouble();
    final percentage = previous != 0 ? (difference / previous) * 100 : 0;

    if (difference > 0) {
      return '+${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else if (difference < 0) {
      return '${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else {
      return '0 (0%)';
    }
  }
}