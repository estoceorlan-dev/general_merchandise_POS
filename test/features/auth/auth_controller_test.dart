import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/features/auth/data/repositories/noop_auth_audit_repository.dart';
import 'package:jce_pos/features/auth/domain/entities/auth_session.dart';
import 'package:jce_pos/features/auth/domain/repositories/auth_audit_repository.dart';
import 'package:jce_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:jce_pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:jce_pos/features/auth/presentation/providers/auth_providers.dart';
import 'package:jce_pos/shared/models/access_role.dart';
import 'package:jce_pos/shared/models/app_user.dart';
import 'package:jce_pos/shared/models/branch.dart';
import 'package:jce_pos/shared/models/branch_access.dart';
import 'package:jce_pos/shared/models/organization.dart';
import 'package:jce_pos/shared/models/organization_access.dart';
import 'package:jce_pos/shared/models/permission.dart';
import 'package:jce_pos/shared/models/user_account_status.dart';

void main() {
  test(
    'restores an authenticated session from the repository stream',
    () async {
      final restored = _session({AppPermission.viewDashboard});
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(initial: restored, refreshed: restored),
          ),
          authAuditRepositoryProvider.overrideWithValue(
            const NoopAuthAuditRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(authControllerProvider.future), restored);
    },
  );

  test('an unresolved application profile is denied safely', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(
            initialError: const AuthException(
              'No application profile.',
              code: 'profile-not-found',
            ),
          ),
        ),
        authAuditRepositoryProvider.overrideWithValue(
          const NoopAuthAuditRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final errorState = Completer<AsyncValue<AuthSession?>>();
    final subscription = container.listen(authControllerProvider, (_, next) {
      if (next.hasError && !errorState.isCompleted) {
        errorState.complete(next);
      }
    }, fireImmediately: true);
    addTearDown(subscription.close);

    final state = await errorState.future.timeout(const Duration(seconds: 2));
    expect(state.error, isA<AuthException>());
  });

  test('refreshed role permissions replace the active access set', () async {
    final initial = _session({AppPermission.viewDashboard});
    final refreshed = _session({
      AppPermission.viewDashboard,
      AppPermission.viewReports,
    });
    final audit = _RecordingAuditRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(initial: initial, refreshed: refreshed),
        ),
        authAuditRepositoryProvider.overrideWithValue(audit),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).refreshAccess();

    expect(
      container.read(authControllerProvider).requireValue?.permissions,
      contains(AppPermission.viewReports),
    );
    expect(audit.roleChanges, 1);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.initial, this.refreshed, this.initialError});

  final AuthSession? initial;
  final AuthSession? refreshed;
  final Object? initialError;

  @override
  Stream<AuthSession?> authStateChanges() {
    final error = initialError;
    return error == null
        ? Stream.value(initial)
        : Stream<AuthSession?>.error(error);
  }

  @override
  Future<AuthSession> refreshAccess() async => refreshed!;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthSession> selectActiveBranch({
    required String organizationId,
    required String branchId,
  }) async {
    return initial!.switchTo(
      organizationId: organizationId,
      branchId: branchId,
    );
  }

  @override
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => initial!;

  @override
  Future<void> signOut() async {}
}

class _RecordingAuditRepository implements AuthAuditRepository {
  int roleChanges = 0;

  @override
  Future<void> recordRoleChange({
    required AuthSession previous,
    required AuthSession current,
  }) async {
    roleChanges += 1;
  }

  @override
  Future<void> recordBranchSwitch({
    required AuthSession previous,
    required AuthSession current,
  }) async {}

  @override
  Future<void> recordLogin(AuthSession session) async {}

  @override
  Future<void> recordLoginFailed(String email, {String? reason}) async {}

  @override
  Future<void> recordLogout(AuthSession session) async {}
}

AuthSession _session(Set<AppPermission> permissions) {
  final role = AccessRole(
    id: 'role',
    code: permissions.map((permission) => permission.code).join('-'),
    name: 'Test Role',
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
            id: 'org',
            code: 'ORG',
            name: 'Organization',
            timezone: 'Asia/Manila',
          ),
          status: UserAccountStatus.active,
          organizationRoles: const [],
          branches: [
            BranchAccess(
              branch: const Branch(
                id: 'branch',
                organizationId: 'org',
                code: 'MAIN',
                name: 'Main',
                timezone: 'Asia/Manila',
              ),
              roles: [role],
            ),
          ],
        ),
      ],
    ),
    activeOrganizationId: 'org',
    activeBranchId: 'branch',
  );
}
