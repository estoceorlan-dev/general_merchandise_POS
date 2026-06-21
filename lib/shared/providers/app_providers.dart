import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sync_state.dart';
import '../models/user_role.dart';

final currentBranchIdProvider = Provider<String?>((ref) => null);

final currentUserRoleProvider = Provider<UserRole>((ref) {
  return UserRole.admin;
});

final syncStateProvider = Provider<SyncState>((ref) {
  return const SyncState(status: SyncStatus.idle);
});
