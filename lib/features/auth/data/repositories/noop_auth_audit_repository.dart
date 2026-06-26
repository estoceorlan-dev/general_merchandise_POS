import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_audit_repository.dart';

class NoopAuthAuditRepository implements AuthAuditRepository {
  const NoopAuthAuditRepository();

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

  @override
  Future<void> recordRoleChange({
    required AuthSession previous,
    required AuthSession current,
  }) async {}
}
