import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/sale_summary.dart';
import '../../domain/repositories/sales_repository.dart';

class DriftSalesRepository implements SalesRepository {
  const DriftSalesRepository();

  @override
  Future<void> queueSaleForSync({
    required BusinessContext context,
    required SaleSummary sale,
  }) {
    throw UnimplementedError('Add Drift sale tables before queueing sales.');
  }

  @override
  Stream<List<SaleSummary>> watchRecentSales({
    required BusinessContext context,
  }) {
    return const Stream<List<SaleSummary>>.empty();
  }
}
