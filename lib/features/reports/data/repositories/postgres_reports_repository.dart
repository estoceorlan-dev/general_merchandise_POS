import '../../domain/repositories/reports_repository.dart';

class PostgresReportsRepository implements ReportsRepository {
  const PostgresReportsRepository();

  @override
  Future<void> refreshDashboardMetrics({String? branchId}) {
    throw UnimplementedError(
      'Connect the PostgreSQL reporting API before refreshing metrics.',
    );
  }
}
