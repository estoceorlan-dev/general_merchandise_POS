import '../../../../shared/models/inventory_snapshot.dart';

abstract interface class InventoryRepository {
  Stream<List<InventorySnapshot>> watchInventory({String? branchId});
  Future<void> queueInventoryAdjustment(String productId, num quantityDelta);
}
