enum SyncStatus { idle, syncing, offline, failed }

class SyncState {
  const SyncState({
    required this.status,
    this.lastSyncedAt,
    this.pendingChanges = 0,
    this.message,
  });

  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final int pendingChanges;
  final String? message;
}
