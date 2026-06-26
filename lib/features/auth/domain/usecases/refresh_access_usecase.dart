import '../entities/auth_session.dart';
import '../repositories/auth_audit_repository.dart';
import '../repositories/auth_repository.dart';

class RefreshAccessUseCase {
  const RefreshAccessUseCase({
    required AuthRepository authRepository,
    required AuthAuditRepository auditRepository,
  }) : _authRepository = authRepository,
       _auditRepository = auditRepository;

  final AuthRepository _authRepository;
  final AuthAuditRepository _auditRepository;

  Future<AuthSession> call(AuthSession previous) async {
    final current = await _authRepository.refreshAccess();
    if (_roleSignature(previous) != _roleSignature(current)) {
      await _auditRepository.recordRoleChange(
        previous: previous,
        current: current,
      );
    }
    return current;
  }

  String _roleSignature(AuthSession session) {
    final roleCodes = session.roles.map((role) => role.code).toList()..sort();
    final permissions =
        session.permissions.map((permission) => permission.code).toList()
          ..sort();
    return [...roleCodes, '|', ...permissions].join(',');
  }
}
