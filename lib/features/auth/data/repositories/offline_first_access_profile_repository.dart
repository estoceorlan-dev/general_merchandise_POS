import '../../../../shared/models/app_user.dart';
import '../../domain/repositories/access_profile_repository.dart';
import '../datasources/access_local_data_source.dart';
import '../datasources/access_remote_data_source.dart';

class OfflineFirstAccessProfileRepository implements AccessProfileRepository {
  const OfflineFirstAccessProfileRepository({
    required AccessLocalDataSource local,
    required AccessRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final AccessLocalDataSource _local;
  final AccessRemoteDataSource _remote;

  @override
  Future<AppUser?> loadProfile({
    required String firebaseUid,
    required String email,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _local.findByFirebaseUid(firebaseUid);
      if (cached != null) {
        _refreshInBackground(firebaseUid: firebaseUid, email: email);
        return cached;
      }
    }

    try {
      final remote = await _remote.fetchCurrentProfile(
        firebaseUid: firebaseUid,
        email: email,
      );
      if (remote == null) {
        await _local.clearProfile(firebaseUid);
        return null;
      }
      await _local.replaceProfile(remote);
      return remote;
    } on AccessProfileRejectedException {
      await _local.clearProfile(firebaseUid);
      rethrow;
    } catch (_) {
      return _local.findByFirebaseUid(firebaseUid);
    }
  }

  Future<void> _refreshInBackground({
    required String firebaseUid,
    required String email,
  }) async {
    try {
      final remote = await _remote.fetchCurrentProfile(
        firebaseUid: firebaseUid,
        email: email,
      );
      if (remote != null) {
        await _local.replaceProfile(remote);
      }
    } catch (_) {
      // Cached access remains usable while the remote source is unavailable.
    }
  }
}
