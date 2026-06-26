import '../../../../shared/models/business_context.dart';

abstract interface class TransfersRepository {
  Future<void> queueBranchTransfer({
    required BusinessContext context,
    required String destinationBranchId,
    required String productId,
    required num quantity,
  });
}
