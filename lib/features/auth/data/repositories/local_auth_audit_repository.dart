import '../../../../core/logger/app_logger.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/models/audit_log_entry.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_audit_repository.dart';
import '../../domain/repositories/device_registration_repository.dart';

class LocalAuthAuditRepository implements AuthAuditRepository {
  const LocalAuthAuditRepository({
    required AuditLogService auditLogService,
    required DeviceRegistrationRepository deviceRegistrationRepository,
    required IdGenerator idGenerator,
    required AppClock clock,
    required AppLogger logger,
  }) : _auditLogService = auditLogService,
       _deviceRegistrationRepository = deviceRegistrationRepository,
       _idGenerator = idGenerator,
       _clock = clock,
       _logger = logger;

  final AuditLogService _auditLogService;
  final DeviceRegistrationRepository _deviceRegistrationRepository;
  final IdGenerator _idGenerator;
  final AppClock _clock;
  final AppLogger _logger;

  @override
  Future<void> recordLogin(AuthSession session) {
    return _record(
      session: session,
      actionType: AuditActionType.login,
      entityName: 'authentication',
      entityId: session.user.firebaseUid,
    );
  }

  @override
  Future<void> recordLoginFailed(String email, {String? reason}) {
    return _recordAnonymous(
      actorUserId: 'anonymous:${email.trim().toLowerCase()}',
      actionType: AuditActionType.loginFailed,
      entityName: 'authentication',
      entityId: email.trim().toLowerCase(),
      metadata: {'reason': reason},
    );
  }

  @override
  Future<void> recordLogout(AuthSession session) {
    return _record(
      session: session,
      actionType: AuditActionType.logout,
      entityName: 'authentication',
      entityId: session.user.firebaseUid,
    );
  }

  @override
  Future<void> recordBranchSwitch({
    required AuthSession previous,
    required AuthSession current,
  }) {
    return _record(
      session: current,
      actionType: AuditActionType.branchSwitch,
      entityName: 'branch',
      entityId: current.activeBranchId,
      metadata: {
        'previousOrganizationId': previous.activeOrganizationId,
        'previousBranchId': previous.activeBranchId,
      },
    );
  }

  @override
  Future<void> recordRoleChange({
    required AuthSession previous,
    required AuthSession current,
  }) {
    return _record(
      session: current,
      actionType: AuditActionType.roleChange,
      entityName: 'user_access',
      entityId: current.activeOrganization.appUserId,
      metadata: {
        'previousRoleCodes': previous.roles.map((role) => role.code).toList(),
        'currentRoleCodes': current.roles.map((role) => role.code).toList(),
      },
    );
  }

  Future<void> _record({
    required AuthSession session,
    required AuditActionType actionType,
    required String entityName,
    required String entityId,
    Map<String, Object?> metadata = const {},
  }) async {
    await _write(
      AuditLogEntry(
        id: _idGenerator.newId(),
        organizationId: session.activeOrganizationId,
        actorUserId: session.activeOrganization.appUserId,
        branchId: session.activeBranchId,
        deviceId: await _deviceRegistrationRepository.deviceId(),
        actionType: actionType,
        entityName: entityName,
        entityId: entityId,
        metadata: metadata,
        createdAt: _clock.nowUtc(),
      ),
    );
  }

  Future<void> _recordAnonymous({
    required String actorUserId,
    required AuditActionType actionType,
    required String entityName,
    required String entityId,
    Map<String, Object?> metadata = const {},
  }) async {
    await _write(
      AuditLogEntry(
        id: _idGenerator.newId(),
        actorUserId: actorUserId,
        deviceId: await _deviceRegistrationRepository.deviceId(),
        actionType: actionType,
        entityName: entityName,
        entityId: entityId,
        metadata: metadata,
        createdAt: _clock.nowUtc(),
      ),
    );
  }

  Future<void> _write(AuditLogEntry entry) async {
    final result = await _auditLogService.record(entry);
    if (result case FailureResult(:final failure)) {
      _logger.warning(
        'Authentication audit event could not be recorded.',
        scope: 'auth.audit',
        error: failure,
        stackTrace: failure.stackTrace,
      );
    }
  }
}
