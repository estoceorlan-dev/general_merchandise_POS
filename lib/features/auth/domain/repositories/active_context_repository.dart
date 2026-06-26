import '../../../../shared/models/app_user.dart';
import '../entities/auth_session.dart';

abstract interface class ActiveContextRepository {
  Future<AuthSession> restore(AppUser user);
  Future<void> save(AuthSession session);
  Future<void> clear(String firebaseUid);
}
