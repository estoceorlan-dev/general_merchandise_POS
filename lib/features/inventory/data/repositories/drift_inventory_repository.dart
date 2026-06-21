import '../../../../shared/models/inventory_snapshot.dart';
import '../../domain/repositories/inventory_repository.dart';

class DriftInventoryRepository implements InventoryRepository {
  const DriftInventoryRepository();

  @override
  Future<void> queueInventoryAdjustment(String productId, num quantityDelta) {
    throw UnimplementedError(
      'Add Drift inventory tables before queueing adjustments.',
    );
  }

  @override
  Stream<List<InventorySnapshot>> watchInventory({String? branchId}) {
    return const Stream<List<InventorySnapshot>>.empty();
  }
}
