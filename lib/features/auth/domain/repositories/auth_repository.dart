import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Stream<AuthSession?> authStateChanges();
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<AuthSession> selectActiveBranch({
    required String organizationId,
    required String branchId,
  });
  Future<AuthSession> refreshAccess();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;
}
