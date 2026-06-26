import '../../../../core/error/failure.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../features/auth/domain/entities/auth_session.dart';
import '../../../../features/auth/domain/usecases/require_permission_usecase.dart';
import '../../../../shared/models/business_context.dart';
import '../../../../shared/models/permission.dart';
import '../repositories/branches_repository.dart';

class UpdateBranchNameUseCase {
  const UpdateBranchNameUseCase({
    required BranchesRepository repository,
    required RequirePermissionUseCase requirePermission,
  }) : _repository = repository,
       _requirePermission = requirePermission;

  final BranchesRepository _repository;
  final RequirePermissionUseCase _requirePermission;

  Future<Result<void, Failure>> call({
    required AuthSession? session,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.length < 2 || normalizedName.length > 80) {
      return const Result.failure(
        ValidationFailure(
          'Branch name must contain between 2 and 80 characters.',
        ),
      );
    }
    if (session == null) {
      return const Result.failure(
        AuthorizationFailure('Authentication is required.'),
      );
    }

    final context = BusinessContext(
      organizationId: session.activeOrganizationId,
      branchId: session.activeBranchId,
      actorUserId: session.activeOrganization.appUserId,
    );
    final authorization = _requirePermission(
      session: session,
      permission: AppPermission.manageSettings,
      organizationId: context.organizationId,
      branchId: context.branchId,
    );
    if (authorization case FailureResult(:final failure)) {
      return Result.failure(failure);
    }

    return _repository.updateBranchName(context: context, name: normalizedName);
  }
}
