import '../entities/auth_session.dart';
import '../repositories/auth_audit_repository.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase({
    required AuthRepository authRepository,
    required AuthAuditRepository auditRepository,
  }) : _authRepository = authRepository,
       _auditRepository = auditRepository;

  final AuthRepository _authRepository;
  final AuthAuditRepository _auditRepository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auditRepository.recordLogin(session);
      return session;
    } on AuthException catch (error) {
      await _auditRepository.recordLoginFailed(email, reason: error.code);
      rethrow;
    }
  }
}
