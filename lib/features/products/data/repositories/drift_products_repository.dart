import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/product_summary.dart';
import '../../domain/repositories/products_repository.dart';

class DriftProductsRepository implements ProductsRepository {
  const DriftProductsRepository();

  @override
  Future<void> queueProductSync({
    required BusinessContext context,
    required String productId,
  }) {
    throw UnimplementedError(
      'Add Drift product tables before syncing products.',
    );
  }

  @override
  Stream<List<ProductSummary>> watchProducts({
    required BusinessContext context,
  }) {
    return const Stream<List<ProductSummary>>.empty();
  }
}
