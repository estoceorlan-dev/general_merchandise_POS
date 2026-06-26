import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/sale_summary.dart';

abstract interface class SalesRepository {
  Stream<List<SaleSummary>> watchRecentSales({
    required BusinessContext context,
  });
  Future<void> queueSaleForSync({
    required BusinessContext context,
    required SaleSummary sale,
  });
}
