abstract interface class TransfersRepository {
  Future<void> queueBranchTransfer({
    required String sourceBranchId,
    required String destinationBranchId,
    required String productId,
    required num quantity,
  });
}
