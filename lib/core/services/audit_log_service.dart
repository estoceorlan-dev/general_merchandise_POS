import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/audit_log_entry.dart';

final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  return const LocalAuditLogQueueService();
});

abstract interface class AuditLogService {
  Future<void> record(AuditLogEntry entry);
}

class LocalAuditLogQueueService implements AuditLogService {
  const LocalAuditLogQueueService();

  @override
  Future<void> record(AuditLogEntry entry) {
    throw UnimplementedError(
      'Add Drift tables before persisting queued audit logs.',
    );
  }
}
