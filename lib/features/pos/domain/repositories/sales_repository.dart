import '../../../../shared/models/sale_summary.dart';

abstract interface class SalesRepository {
  Stream<List<SaleSummary>> watchRecentSales({String? branchId});
  Future<void> queueSaleForSync(SaleSummary sale);
}
