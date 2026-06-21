abstract interface class PurchasesRepository {
  Future<void> queuePurchaseOrder({
    required String supplierId,
    required String branchId,
  });
}
