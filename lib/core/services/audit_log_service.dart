import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/audit_log_dao.dart';
import '../database/database_provider.dart';
import '../error/failure.dart';
import '../error/failures.dart';
import '../error/result.dart';
import '../../shared/models/audit_log_entry.dart';

final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  return LocalAuditLogQueueService(ref.watch(auditLogDaoProvider));
});

abstract interface class AuditLogService {
  Future<Result<void, Failure>> record(AuditLogEntry entry);
}

class LocalAuditLogQueueService implements AuditLogService {
  const LocalAuditLogQueueService(this._auditLogDao);

  final AuditLogDao _auditLogDao;

  @override
  Future<Result<void, Failure>> record(AuditLogEntry entry) async {
    try {
      await _auditLogDao.append(entry);
      return const Result.success(null);
    } catch (error, stackTrace) {
      return Result.failure(
        DatabaseFailure(
          'The audit log entry could not be saved.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
