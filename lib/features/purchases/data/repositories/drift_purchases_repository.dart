import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/purchases_repository.dart';

class DriftPurchasesRepository implements PurchasesRepository {
  const DriftPurchasesRepository();

  @override
  Future<void> queuePurchaseOrder({
    required BusinessContext context,
    required String supplierId,
  }) {
    throw UnimplementedError(
      'Add Drift purchase tables before queueing purchase orders.',
    );
  }
}
