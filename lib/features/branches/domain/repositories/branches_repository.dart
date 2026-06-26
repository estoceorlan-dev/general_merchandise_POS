import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../shared/models/business_context.dart';

abstract interface class BranchesRepository {
  Future<Result<void, Failure>> updateBranchName({
    required BusinessContext context,
    required String name,
  });
}
