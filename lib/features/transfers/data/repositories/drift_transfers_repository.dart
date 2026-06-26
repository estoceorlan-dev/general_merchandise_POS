import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/transfers_repository.dart';

class DriftTransfersRepository implements TransfersRepository {
  const DriftTransfersRepository();

  @override
  Future<void> queueBranchTransfer({
    required BusinessContext context,
    required String destinationBranchId,
    required String productId,
    required num quantity,
  }) {
    throw UnimplementedError(
      'Add Drift transfer tables before queueing branch transfers.',
    );
  }
}
