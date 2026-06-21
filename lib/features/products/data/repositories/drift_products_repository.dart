import '../../../../shared/models/product_summary.dart';
import '../../domain/repositories/products_repository.dart';

class DriftProductsRepository implements ProductsRepository {
  const DriftProductsRepository();

  @override
  Future<void> queueProductSync(String productId) {
    throw UnimplementedError(
      'Add Drift product tables before syncing products.',
    );
  }

  @override
  Stream<List<ProductSummary>> watchProducts({String? branchId}) {
    return const Stream<List<ProductSummary>>.empty();
  }
}
