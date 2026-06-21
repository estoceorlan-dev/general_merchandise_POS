import '../../../../shared/models/audit_log_entry.dart';

abstract interface class LogsRepository {
  Stream<List<AuditLogEntry>> watchAuditTrail({String? branchId});
}
