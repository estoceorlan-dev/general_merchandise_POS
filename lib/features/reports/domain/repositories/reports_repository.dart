import '../../../../shared/models/business_context.dart';

abstract interface class ReportsRepository {
  Future<void> refreshDashboardMetrics({required BusinessContext context});
}
