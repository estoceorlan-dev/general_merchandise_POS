import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/local_mutation_transaction.dart';
import '../../../../core/database/models/outbox_command.dart';
import '../../../../core/database/models/outbox_state.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/models/audit_log_entry.dart';
import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/branches_repository.dart';

class OfflineFirstBranchesRepository implements BranchesRepository {
  const OfflineFirstBranchesRepository({
    required FirebaseFunctions functions,
    required String functionName,
    required LocalMutationTransaction localMutationTransaction,
    required IdGenerator idGenerator,
    required AppClock clock,
  }) : _functions = functions,
       _functionName = functionName,
       _localMutationTransaction = localMutationTransaction,
       _idGenerator = idGenerator,
       _clock = clock;

  final FirebaseFunctions _functions;
  final String _functionName;
  final LocalMutationTransaction _localMutationTransaction;
  final IdGenerator _idGenerator;
  final AppClock _clock;

  @override
  Future<Result<void, Failure>> updateBranchName({
    required BusinessContext context,
    required String name,
  }) async {
    try {
      final now = _clock.nowUtc();
      var remoteSucceeded = false;
      try {
        await _functions.httpsCallable(_functionName).call({
          'organizationId': context.organizationId,
          'branchId': context.branchId,
          'name': name,
        });
        remoteSucceeded = true;
      } on FirebaseFunctionsException catch (error) {
        if (error.code == 'permission-denied' ||
            error.code == 'unauthenticated' ||
            error.code == 'invalid-argument') {
          rethrow;
        }
      } catch (_) {
        // The local update remains usable and is queued for later delivery.
      }

      final operationId = _idGenerator.newId();
      return _localMutationTransaction.execute(
        businessWrite: (database) async {
          final updated =
              await (database.update(database.branches)..where(
                    (branch) =>
                        branch.id.equals(context.branchId) &
                        branch.organizationId.equals(context.organizationId),
                  ))
                  .write(
                    BranchesCompanion(name: Value(name), updatedAt: Value(now)),
                  );
          if (updated != 1) {
            throw StateError('The active branch is not cached locally.');
          }
        },
        auditEntry: AuditLogEntry(
          id: _idGenerator.newId(),
          operationId: operationId,
          organizationId: context.organizationId,
          actorUserId: context.actorUserId,
          branchId: context.branchId,
          actionType: AuditActionType.update,
          entityName: 'branch',
          entityId: context.branchId,
          metadata: {'name': name},
          createdAt: now,
        ),
        outboxCommand: OutboxCommand(
          operationId: operationId,
          organizationId: context.organizationId,
          branchId: context.branchId,
          commandType: 'branch.update_name',
          aggregateType: 'branch',
          aggregateId: context.branchId,
          payload: {'name': name},
          createdAt: now,
          state: remoteSucceeded ? OutboxState.succeeded : OutboxState.pending,
        ),
      );
    } catch (error, stackTrace) {
      return Result.failure(FailureMapper.fromException(error, stackTrace));
    }
  }
}
