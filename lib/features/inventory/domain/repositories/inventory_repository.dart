import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/inventory_snapshot.dart';

abstract interface class InventoryRepository {
  Stream<List<InventorySnapshot>> watchInventory({
    required BusinessContext context,
  });
  Future<void> queueInventoryAdjustment({
    required BusinessContext context,
    required String productId,
    required num quantityDelta,
  });
}
