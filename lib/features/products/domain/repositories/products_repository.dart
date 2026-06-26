import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/product_summary.dart';

abstract interface class ProductsRepository {
  Stream<List<ProductSummary>> watchProducts({
    required BusinessContext context,
  });
  Future<void> queueProductSync({
    required BusinessContext context,
    required String productId,
  });
}
