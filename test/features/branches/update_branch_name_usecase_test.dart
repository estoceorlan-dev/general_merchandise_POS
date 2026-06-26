import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/error/failure.dart';
import 'package:jce_pos/core/error/result.dart';
import 'package:jce_pos/features/auth/domain/entities/auth_session.dart';
import 'package:jce_pos/features/auth/domain/usecases/require_permission_usecase.dart';
import 'package:jce_pos/features/branches/domain/repositories/branches_repository.dart';
import 'package:jce_pos/features/branches/domain/usecases/update_branch_name_usecase.dart';
import 'package:jce_pos/shared/models/access_role.dart';
import 'package:jce_pos/shared/models/app_user.dart';
import 'package:jce_pos/shared/models/branch.dart';
import 'package:jce_pos/shared/models/branch_access.dart';
import 'package:jce_pos/shared/models/business_context.dart';
import 'package:jce_pos/shared/models/organization.dart';
import 'package:jce_pos/shared/models/organization_access.dart';
import 'package:jce_pos/shared/models/permission.dart';
import 'package:jce_pos/shared/models/user_account_status.dart';

void main() {
  test('authorized users can update the active branch name', () async {
    final repository = _RecordingBranchesRepository();
    final useCase = UpdateBranchNameUseCase(
      repository: repository,
      requirePermission: const RequirePermissionUseCase(),
    );

    final result = await useCase(
      session: _session({AppPermission.manageSettings}),
      name: '  JCE Downtown  ',
    );

    expect(result.isSuccess, isTrue);
    expect(repository.name, 'JCE Downtown');
    expect(repository.context?.branchId, 'branch');
    expect(repository.context?.organizationId, 'organization');
  });

  test('users without settings permission are denied', () async {
    final repository = _RecordingBranchesRepository();
    final useCase = UpdateBranchNameUseCase(
      repository: repository,
      requirePermission: const RequirePermissionUseCase(),
    );

    final result = await useCase(
      session: _session({AppPermission.viewDashboard}),
      name: 'JCE Downtown',
    );

    expect(result.isFailure, isTrue);
    expect(repository.name, isNull);
  });

  test('invalid branch names are rejected before persistence', () async {
    final repository = _RecordingBranchesRepository();
    final useCase = UpdateBranchNameUseCase(
      repository: repository,
      requirePermission: const RequirePermissionUseCase(),
    );

    final result = await useCase(
      session: _session({AppPermission.manageSettings}),
      name: 'A',
    );

    expect(result.isFailure, isTrue);
    expect(repository.name, isNull);
  });
}

class _RecordingBranchesRepository implements BranchesRepository {
  BusinessContext? context;
  String? name;

  @override
  Future<Result<void, Failure>> updateBranchName({
    required BusinessContext context,
    required String name,
  }) async {
    this.context = context;
    this.name = name;
    return const Result.success(null);
  }
}

AuthSession _session(Set<AppPermission> permissions) {
  final role = AccessRole(
    id: 'role',
    code: 'settings',
    name: 'Settings Manager',
    permissions: permissions,
  );
  return AuthSession(
    user: AppUser(
      firebaseUid: 'firebase-user',
      email: 'user@jce.test',
      displayName: 'JCE User',
      organizations: [
        OrganizationAccess(
          appUserId: 'app-user',
          organization: const Organization(
            id: 'organization',
            code: 'JCE',
            name: 'JCE',
            timezone: 'Asia/Manila',
          ),
          status: UserAccountStatus.active,
          organizationRoles: const [],
          branches: [
            BranchAccess(
              branch: const Branch(
                id: 'branch',
                organizationId: 'organization',
                code: 'MAIN',
                name: 'Main Branch',
                timezone: 'Asia/Manila',
              ),
              roles: [role],
            ),
          ],
        ),
      ],
    ),
    activeOrganizationId: 'organization',
    activeBranchId: 'branch',
  );
}
