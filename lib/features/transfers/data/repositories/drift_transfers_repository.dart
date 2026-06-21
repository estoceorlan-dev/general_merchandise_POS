import '../../domain/repositories/transfers_repository.dart';

class DriftTransfersRepository implements TransfersRepository {
  const DriftTransfersRepository();

  @override
  Future<void> queueBranchTransfer({
    required String sourceBranchId,
    required String destinationBranchId,
    required String productId,
    required num quantity,
  }) {
    throw UnimplementedError(
      'Add Drift transfer tables before queueing branch transfers.',
    );
  }
}
