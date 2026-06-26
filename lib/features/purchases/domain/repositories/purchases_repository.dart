import '../../../../shared/models/business_context.dart';

abstract interface class PurchasesRepository {
  Future<void> queuePurchaseOrder({
    required BusinessContext context,
    required String supplierId,
  });
}
