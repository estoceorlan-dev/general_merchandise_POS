import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(String email) {
    final normalized = email.trim();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw const AuthException('Enter your email address first.');
    }
    return _authRepository.sendPasswordResetEmail(normalized);
  }
}
