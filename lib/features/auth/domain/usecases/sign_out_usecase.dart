import '../entities/auth_session.dart';
import '../repositories/auth_audit_repository.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase({
    required AuthRepository authRepository,
    required AuthAuditRepository auditRepository,
  }) : _authRepository = authRepository,
       _auditRepository = auditRepository;

  final AuthRepository _authRepository;
  final AuthAuditRepository _auditRepository;

  Future<void> call(AuthSession? session) async {
    if (session != null) {
      await _auditRepository.recordLogout(session);
    }
    await _authRepository.signOut();
  }
}
