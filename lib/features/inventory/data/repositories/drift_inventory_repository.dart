import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/inventory_snapshot.dart';
import '../../domain/repositories/inventory_repository.dart';

class DriftInventoryRepository implements InventoryRepository {
  const DriftInventoryRepository();

  @override
  Future<void> queueInventoryAdjustment({
    required BusinessContext context,
    required String productId,
    required num quantityDelta,
  }) {
    throw UnimplementedError(
      'Add Drift inventory tables before queueing adjustments.',
    );
  }

  @override
  Stream<List<InventorySnapshot>> watchInventory({
    required BusinessContext context,
  }) {
    return const Stream<List<InventorySnapshot>>.empty();
  }
}
