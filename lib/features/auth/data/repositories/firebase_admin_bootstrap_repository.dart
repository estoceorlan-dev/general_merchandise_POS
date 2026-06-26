import 'package:drift/drift.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/utils/app_clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/models/permission.dart';
import '../../../../shared/models/user_account_status.dart';
import '../../domain/repositories/admin_bootstrap_repository.dart';

class FirebaseAdminBootstrapRepository implements AdminBootstrapRepository {
  const FirebaseAdminBootstrapRepository({
    required firebase.FirebaseAuth firebaseAuth,
    required FirebaseFunctions functions,
    required String functionName,
    required db.AppDatabase database,
    required AppClock clock,
    required IdGenerator idGenerator,
  }) : _firebaseAuth = firebaseAuth,
       _functions = functions,
       _functionName = functionName,
       _database = database,
       _clock = clock,
       _idGenerator = idGenerator;

  static const email = 'estoce.orlan@gmail.com';
  static const password = 'qwerty1234';
  static const displayName = 'Jce-Admin';

  static const _adminRoleCode = 'admin';
  static const _adminRoleName = 'Admin';
  static const _defaultOrganizationCode = 'JCE';
  static const _defaultOrganizationName = 'JCE General Merchandise';
  static const _defaultBranchCode = 'MAIN';
  static const _defaultBranchName = 'Main Branch';
  static const _defaultTimezone = 'Asia/Manila';

  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;
  final String _functionName;
  final db.AppDatabase _database;
  final AppClock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<AdminBootstrapResult> createTemporaryAdminAccount() async {
    final firebaseUid = await _ensureFirebaseAccount();
    try {
      await _seedRemoteAccessProfile();
      final appUserId = await _seedLocalAccessProfile(firebaseUid);
      return AdminBootstrapResult(
        appUserId: appUserId,
        firebaseUid: firebaseUid,
        email: email,
        password: password,
        displayName: displayName,
      );
    } finally {
      final currentEmail = _firebaseAuth.currentUser?.email
          ?.trim()
          .toLowerCase();
      if (currentEmail == email) {
        await _firebaseAuth.signOut();
      }
    }
  }

  Future<void> _seedRemoteAccessProfile() async {
    try {
      await _functions.httpsCallable(_functionName).call<Object?>();
    } on FirebaseFunctionsException catch (error) {
      throw AdminBootstrapException(_messageForFunctionsCode(error.code));
    } catch (_) {
      throw const AdminBootstrapException(
        'The temporary admin backend bootstrap could not be completed.',
      );
    }
  }

  Future<String> _ensureFirebaseAccount() async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AdminBootstrapException(
          'Firebase did not return the created admin account.',
        );
      }
      await user.updateDisplayName(displayName);
      return user.uid;
    } on firebase.FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        return _signInExistingAdminAccount();
      }
      throw AdminBootstrapException(_messageForFirebaseCode(error.code));
    }
  }

  Future<String> _signInExistingAdminAccount() async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AdminBootstrapException(
          'Firebase did not return the existing admin account.',
        );
      }
      await user.updateDisplayName(displayName);
      return user.uid;
    } on firebase.FirebaseAuthException catch (error) {
      throw AdminBootstrapException(
        error.code == 'invalid-credential' || error.code == 'wrong-password'
            ? 'The admin email already exists, but it does not use qwerty1234.'
            : _messageForFirebaseCode(error.code),
      );
    }
  }

  Future<String> _seedLocalAccessProfile(String firebaseUid) {
    return _database.transaction(() async {
      final now = _clock.nowUtc();
      final organizationId = await _resolveOrganizationId(now);
      await _ensureBranch(organizationId: organizationId, now: now);
      final roleId = await _resolveAdminRoleId(
        organizationId: organizationId,
        now: now,
      );
      await _replaceRolePermissions(roleId: roleId, now: now);
      final appUserId = await _resolveAppUserId(
        organizationId: organizationId,
        firebaseUid: firebaseUid,
        now: now,
      );
      await _ensureOrganizationRoleAssignment(
        organizationId: organizationId,
        userId: appUserId,
        roleId: roleId,
        now: now,
      );
      return appUserId;
    });
  }

  Future<String> _resolveOrganizationId(DateTime now) async {
    final jceOrganization =
        await (_database.select(_database.organizations)..where(
              (row) =>
                  row.code.equals(_defaultOrganizationCode) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (jceOrganization != null) {
      await (_database.update(
        _database.organizations,
      )..where((row) => row.id.equals(jceOrganization.id))).write(
        db.OrganizationsCompanion(
          isActive: const Value<bool>(true),
          updatedAt: Value<DateTime>(now),
          deletedAt: const Value<DateTime?>(null),
        ),
      );
      return jceOrganization.id;
    }

    final activeOrganizations =
        await (_database.select(_database.organizations)
              ..where(
                (row) => row.isActive.equals(true) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)])
              ..limit(1))
            .get();
    final activeOrganization = activeOrganizations.firstOrNull;
    if (activeOrganization != null) {
      return activeOrganization.id;
    }

    final organizationId = _idGenerator.newId();
    await _database
        .into(_database.organizations)
        .insert(
          db.OrganizationsCompanion.insert(
            id: organizationId,
            code: _defaultOrganizationCode,
            name: _defaultOrganizationName,
            timezone: const Value<String>(_defaultTimezone),
            isActive: const Value<bool>(true),
            createdAt: now,
            updatedAt: now,
            deletedAt: const Value<DateTime?>(null),
          ),
        );
    return organizationId;
  }

  Future<String> _ensureBranch({
    required String organizationId,
    required DateTime now,
  }) async {
    final activeBranches =
        await (_database.select(_database.branches)
              ..where(
                (row) =>
                    row.organizationId.equals(organizationId) &
                    row.isActive.equals(true) &
                    row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)])
              ..limit(1))
            .get();
    final activeBranch = activeBranches.firstOrNull;
    if (activeBranch != null) {
      return activeBranch.id;
    }

    final branchId = _idGenerator.newId();
    await _database
        .into(_database.branches)
        .insert(
          db.BranchesCompanion.insert(
            id: branchId,
            organizationId: organizationId,
            code: _defaultBranchCode,
            name: _defaultBranchName,
            timezone: const Value<String>(_defaultTimezone),
            isActive: const Value<bool>(true),
            createdAt: now,
            updatedAt: now,
            deletedAt: const Value<DateTime?>(null),
          ),
        );
    return branchId;
  }

  Future<String> _resolveAdminRoleId({
    required String organizationId,
    required DateTime now,
  }) async {
    final existingRole =
        await (_database.select(_database.roles)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.code.equals(_adminRoleCode),
            ))
            .getSingleOrNull();
    if (existingRole != null) {
      await (_database.update(
        _database.roles,
      )..where((row) => row.id.equals(existingRole.id))).write(
        db.RolesCompanion(
          name: const Value<String>(_adminRoleName),
          description: const Value<String>(
            'Full-permission temporary admin role.',
          ),
          isActive: const Value<bool>(true),
          updatedAt: Value<DateTime>(now),
          deletedAt: const Value<DateTime?>(null),
        ),
      );
      return existingRole.id;
    }

    final roleId = _idGenerator.newId();
    await _database
        .into(_database.roles)
        .insert(
          db.RolesCompanion.insert(
            id: roleId,
            organizationId: organizationId,
            code: _adminRoleCode,
            name: _adminRoleName,
            description: const Value<String>(
              'Full-permission temporary admin role.',
            ),
            isActive: const Value<bool>(true),
            createdAt: now,
            updatedAt: now,
            deletedAt: const Value<DateTime?>(null),
          ),
        );
    return roleId;
  }

  Future<void> _replaceRolePermissions({
    required String roleId,
    required DateTime now,
  }) async {
    await (_database.delete(
      _database.rolePermissions,
    )..where((row) => row.roleId.equals(roleId))).go();

    for (final permission in AppPermission.values) {
      await _database
          .into(_database.permissions)
          .insertOnConflictUpdate(
            db.PermissionsCompanion.insert(
              code: permission.code,
              name: permission.code,
              createdAt: now,
            ),
          );
      await _database
          .into(_database.rolePermissions)
          .insert(
            db.RolePermissionsCompanion.insert(
              roleId: roleId,
              permissionCode: permission.code,
              grantedAt: now,
            ),
          );
    }
  }

  Future<String> _resolveAppUserId({
    required String organizationId,
    required String firebaseUid,
    required DateTime now,
  }) async {
    final existingByEmail =
        await (_database.select(_database.appUsers)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.email.equals(email),
            ))
            .getSingleOrNull();
    final existingByFirebaseUid =
        await (_database.select(_database.appUsers)..where(
              (row) =>
                  row.organizationId.equals(organizationId) &
                  row.firebaseUid.equals(firebaseUid),
            ))
            .getSingleOrNull();
    final existingUser = existingByEmail ?? existingByFirebaseUid;
    if (existingUser != null) {
      await (_database.update(
        _database.appUsers,
      )..where((row) => row.id.equals(existingUser.id))).write(
        db.AppUsersCompanion(
          firebaseUid: Value<String?>(firebaseUid),
          email: const Value<String>(email),
          displayName: const Value<String>(displayName),
          status: Value<String>(UserAccountStatus.active.name),
          updatedAt: Value<DateTime>(now),
          deletedAt: const Value<DateTime?>(null),
        ),
      );
      return existingUser.id;
    }

    final appUserId = _idGenerator.newId();
    await _database
        .into(_database.appUsers)
        .insert(
          db.AppUsersCompanion.insert(
            id: appUserId,
            organizationId: organizationId,
            firebaseUid: Value<String?>(firebaseUid),
            email: email,
            displayName: displayName,
            status: UserAccountStatus.active.name,
            createdAt: now,
            updatedAt: now,
            deletedAt: const Value<DateTime?>(null),
          ),
        );
    return appUserId;
  }

  Future<void> _ensureOrganizationRoleAssignment({
    required String organizationId,
    required String userId,
    required String roleId,
    required DateTime now,
  }) {
    return _database
        .into(_database.userRoleAssignments)
        .insertOnConflictUpdate(
          db.UserRoleAssignmentsCompanion.insert(
            id: '$userId:organization:$roleId',
            organizationId: organizationId,
            branchId: const Value<String?>(null),
            userId: userId,
            roleId: roleId,
            assignedAt: now,
            revokedAt: const Value<DateTime?>(null),
          ),
        );
  }

  String _messageForFirebaseCode(String code) {
    return switch (code) {
      'network-request-failed' =>
        'Connect to the internet before creating the Firebase admin account.',
      'operation-not-allowed' =>
        'Email/password authentication is not enabled in Firebase.',
      'weak-password' => 'Firebase rejected qwerty1234 as a weak password.',
      'invalid-email' => 'The configured admin email is invalid.',
      _ => 'The temporary admin account could not be created.',
    };
  }

  String _messageForFunctionsCode(String code) {
    return switch (code) {
      'not-found' =>
        'Deploy the bootstrapTemporaryAdmin function before creating admin access.',
      'unauthenticated' =>
        'Firebase did not authenticate the temporary admin bootstrap call.',
      'permission-denied' =>
        'The temporary admin bootstrap function denied this account.',
      _ => 'The temporary admin access profile could not be created.',
    };
  }
}
