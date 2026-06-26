import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/reports_repository.dart';

class PostgresReportsRepository implements ReportsRepository {
  const PostgresReportsRepository();

  @override
  Future<void> refreshDashboardMetrics({required BusinessContext context}) {
    throw UnimplementedError(
      'Connect the PostgreSQL reporting API before refreshing metrics.',
    );
  }
}
