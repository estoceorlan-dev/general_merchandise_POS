import '../../../../shared/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository();

  @override
  Stream<AppUser?> authStateChanges() {
    return const Stream<AppUser?>.empty();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError('Connect Firebase Auth before signing out.');
  }
}
