abstract interface class ReportsRepository {
  Future<void> refreshDashboardMetrics({String? branchId});
}
