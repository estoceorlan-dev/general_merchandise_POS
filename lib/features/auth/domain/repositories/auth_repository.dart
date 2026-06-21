import '../../../../shared/models/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signOut();
}
