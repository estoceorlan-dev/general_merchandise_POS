import '../../../../shared/models/audit_log_entry.dart';
import '../../domain/repositories/logs_repository.dart';

class DriftLogsRepository implements LogsRepository {
  const DriftLogsRepository();

  @override
  Stream<List<AuditLogEntry>> watchAuditTrail({String? branchId}) {
    return const Stream<List<AuditLogEntry>>.empty();
  }
}
