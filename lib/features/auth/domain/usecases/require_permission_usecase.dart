import '../../../../core/error/failure.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../shared/models/permission.dart';
import '../entities/auth_session.dart';

class RequirePermissionUseCase {
  const RequirePermissionUseCase();

  Result<void, Failure> call({
    required AuthSession? session,
    required AppPermission permission,
    required String organizationId,
    required String branchId,
  }) {
    if (session == null) {
      return const Result.failure(
        AuthorizationFailure('Authentication is required.'),
      );
    }
    if (session.activeOrganizationId != organizationId ||
        session.activeBranchId != branchId) {
      return const Result.failure(
        AuthorizationFailure(
          'The request context does not match the active branch.',
        ),
      );
    }
    if (!session.can(permission)) {
      return Result.failure(
        AuthorizationFailure(
          'Permission ${permission.code} is required for this operation.',
        ),
      );
    }
    return const Result.success(null);
  }
}
