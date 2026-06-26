import '../../../../core/database/daos/audit_log_dao.dart';
import '../../../../shared/models/audit_log_entry.dart';
import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/logs_repository.dart';

class DriftLogsRepository implements LogsRepository {
  const DriftLogsRepository(this._auditLogDao);

  final AuditLogDao _auditLogDao;

  @override
  Stream<List<AuditLogEntry>> watchAuditTrail({
    required BusinessContext context,
  }) {
    return _auditLogDao.watchEntries(
      organizationId: context.organizationId,
      branchId: context.branchId,
    );
  }
}
