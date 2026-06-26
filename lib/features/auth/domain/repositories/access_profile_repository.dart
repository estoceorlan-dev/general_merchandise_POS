import '../../../../shared/models/app_user.dart';

abstract interface class AccessProfileRepository {
  Future<AppUser?> loadProfile({
    required String firebaseUid,
    required String email,
    bool forceRefresh = false,
  });
}
