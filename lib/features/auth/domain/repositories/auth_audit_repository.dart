import '../entities/auth_session.dart';

abstract interface class AuthAuditRepository {
  Future<void> recordLogin(AuthSession session);
  Future<void> recordLoginFailed(String email, {String? reason});
  Future<void> recordLogout(AuthSession session);
  Future<void> recordBranchSwitch({
    required AuthSession previous,
    required AuthSession current,
  });
  Future<void> recordRoleChange({
    required AuthSession previous,
    required AuthSession current,
  });
}
