import '../../../../shared/models/audit_log_entry.dart';
import '../../../../shared/models/business_context.dart';

abstract interface class LogsRepository {
  Stream<List<AuditLogEntry>> watchAuditTrail({
    required BusinessContext context,
  });
}
