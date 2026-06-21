import '../../domain/repositories/purchases_repository.dart';

class DriftPurchasesRepository implements PurchasesRepository {
  const DriftPurchasesRepository();

  @override
  Future<void> queuePurchaseOrder({
    required String supplierId,
    required String branchId,
  }) {
    throw UnimplementedError(
      'Add Drift purchase tables before queueing purchase orders.',
    );
  }
}
