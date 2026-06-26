import 'dart:async';

import '../../../../shared/models/access_role.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/branch.dart';
import '../../../../shared/models/branch_access.dart';
import '../../../../shared/models/organization.dart';
import '../../../../shared/models/organization_access.dart';
import '../../../../shared/models/permission.dart';
import '../../../../shared/models/user_account_status.dart';
import '../../../../shared/models/user_role.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class HardcodedAuthRepository implements AuthRepository {
  HardcodedAuthRepository({required String branchId})
    : _users = _createUsers(branchId);

  static const _demoPassword = 'password123';

  final Map<String, AuthSession> _users;
  final StreamController<AuthSession?> _changes =
      StreamController<AuthSession?>.broadcast();

  AuthSession? _currentSession;

  static Map<String, AuthSession> _createUsers(String branchId) {
    return {
      for (final entry in const <(String, String, UserRole)>[
        ('owner@jce.test', 'JCE Owner', UserRole.owner),
        ('admin@jce.test', 'System Admin', UserRole.admin),
        ('manager@jce.test', 'Branch Manager', UserRole.manager),
        ('cashier@jce.test', 'Cashier Staff', UserRole.cashier),
        ('inventory@jce.test', 'Inventory Clerk', UserRole.inventoryClerk),
        ('auditor@jce.test', 'Audit User', UserRole.auditor),
      ])
        entry.$1: _createSession(
          email: entry.$1,
          displayName: entry.$2,
          role: entry.$3,
          branchId: branchId,
        ),
    };
  }

  static AuthSession _createSession({
    required String email,
    required String displayName,
    required UserRole role,
    required String branchId,
  }) {
    const organizationId = 'demo-organization';
    final accessRole = AccessRole(
      id: 'demo-role-${role.name}',
      code: role.name,
      name: role.label,
      permissions: _demoPermissions(role),
    );
    final organizationAccess = OrganizationAccess(
      appUserId: 'demo-user-${role.name}',
      organization: const Organization(
        id: organizationId,
        code: 'DEMO',
        name: 'JCE Demo Organization',
        timezone: 'Asia/Manila',
      ),
      status: UserAccountStatus.active,
      organizationRoles: const [],
      branches: [
        BranchAccess(
          branch: Branch(
            id: branchId,
            organizationId: organizationId,
            code: 'DEMO',
            name: 'Demo Branch',
            timezone: 'Asia/Manila',
          ),
          roles: [accessRole],
        ),
      ],
    );
    return AuthSession(
      user: AppUser(
        firebaseUid: 'demo-${role.name}',
        email: email,
        displayName: displayName,
        organizations: [organizationAccess],
      ),
      activeOrganizationId: organizationId,
      activeBranchId: branchId,
    );
  }

  @override
  Stream<AuthSession?> authStateChanges() async* {
    yield _currentSession;
    yield* _changes.stream;
  }

  @override
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final session = _users[normalizedEmail];
    if (session == null || password != _demoPassword) {
      throw const AuthException('Email or password is incorrect.');
    }
    _currentSession = session;
    _changes.add(session);
    return session;
  }

  @override
  Future<AuthSession> selectActiveBranch({
    required String organizationId,
    required String branchId,
  }) async {
    final current = _currentSession;
    if (current == null) {
      throw const AuthException('Authentication is required.');
    }
    final updated = current.switchTo(
      organizationId: organizationId,
      branchId: branchId,
    );
    _currentSession = updated;
    _changes.add(updated);
    return updated;
  }

  @override
  Future<AuthSession> refreshAccess() async {
    final current = _currentSession;
    if (current == null) {
      throw const AuthException('Authentication is required.');
    }
    return current;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _currentSession = null;
    _changes.add(null);
  }

  static Set<AppPermission> _demoPermissions(UserRole role) {
    return switch (role) {
      UserRole.owner || UserRole.admin => {...AppPermission.values},
      UserRole.manager => {
        AppPermission.viewDashboard,
        AppPermission.processSales,
        AppPermission.manageProducts,
        AppPermission.manageInventory,
        AppPermission.approveTransfers,
        AppPermission.createPurchases,
        AppPermission.viewReports,
        AppPermission.viewAuditLogs,
      },
      UserRole.cashier => {
        AppPermission.viewDashboard,
        AppPermission.processSales,
      },
      UserRole.inventoryClerk => {
        AppPermission.viewDashboard,
        AppPermission.manageProducts,
        AppPermission.manageInventory,
        AppPermission.approveTransfers,
        AppPermission.createPurchases,
      },
      UserRole.auditor => {
        AppPermission.viewDashboard,
        AppPermission.viewReports,
        AppPermission.viewAuditLogs,
      },
    };
  }
}
