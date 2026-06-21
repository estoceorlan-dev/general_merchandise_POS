import '../../../../shared/models/product_summary.dart';

abstract interface class ProductsRepository {
  Stream<List<ProductSummary>> watchProducts({String? branchId});
  Future<void> queueProductSync(String productId);
}
