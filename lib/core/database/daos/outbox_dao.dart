import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/outbox_command.dart';
import '../models/outbox_state.dart';
import '../outbox_retry_policy.dart';
import '../tables/sync_outbox_table.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutboxEntries])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.attachedDatabase);

  Future<void> enqueue(OutboxCommand command) {
    return into(syncOutboxEntries).insert(
      SyncOutboxEntriesCompanion.insert(
        operationId: command.operationId,
        organizationId: Value(command.organizationId),
        branchId: Value(command.branchId),
        commandType: command.commandType,
        aggregateType: command.aggregateType,
        aggregateId: command.aggregateId,
        payloadJson: command.payloadJson,
        status: command.state.databaseValue,
        createdAt: command.createdAt.toUtc(),
        updatedAt: command.createdAt.toUtc(),
      ),
    );
  }

  Stream<int> watchPendingCount() {
    final count = syncOutboxEntries.operationId.count();
    final query = selectOnly(syncOutboxEntries)
      ..addColumns([count])
      ..where(
        syncOutboxEntries.status.isIn([
          OutboxState.pending.databaseValue,
          OutboxState.processing.databaseValue,
          OutboxState.retryableFailure.databaseValue,
        ]),
      );

    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<int> pendingCount() async {
    return watchPendingCount().first;
  }

  Future<List<SyncOutboxEntry>> claimEligibleBatch({
    required DateTime now,
    int limit = 25,
  }) {
    return transaction(() async {
      final utcNow = now.toUtc();
      final query = select(syncOutboxEntries)
        ..where(
          (row) =>
              row.status.equals(OutboxState.pending.databaseValue) |
              (row.status.equals(OutboxState.retryableFailure.databaseValue) &
                  (row.nextAttemptAt.isNull() |
                      row.nextAttemptAt.isSmallerOrEqualValue(utcNow))),
        )
        ..orderBy([
          (row) => OrderingTerm.asc(row.createdAt),
          (row) => OrderingTerm.asc(row.operationId),
        ])
        ..limit(limit);

      final entries = await query.get();
      for (final entry in entries) {
        await (update(
          syncOutboxEntries,
        )..where((row) => row.operationId.equals(entry.operationId))).write(
          SyncOutboxEntriesCompanion(
            status: Value(OutboxState.processing.databaseValue),
            attemptCount: Value(entry.attemptCount + 1),
            updatedAt: Value(utcNow),
          ),
        );
      }

      return entries
          .map(
            (entry) => entry.copyWith(
              status: OutboxState.processing.databaseValue,
              attemptCount: entry.attemptCount + 1,
              updatedAt: utcNow,
            ),
          )
          .toList(growable: false);
    });
  }

  Future<int> markSucceeded({
    required String operationId,
    required DateTime now,
  }) {
    return (update(
      syncOutboxEntries,
    )..where((row) => row.operationId.equals(operationId))).write(
      SyncOutboxEntriesCompanion(
        status: Value(OutboxState.succeeded.databaseValue),
        nextAttemptAt: const Value(null),
        lastError: const Value(null),
        updatedAt: Value(now.toUtc()),
      ),
    );
  }

  Future<OutboxState?> markFailed({
    required String operationId,
    required String error,
    required DateTime now,
    OutboxRetryPolicy policy = const OutboxRetryPolicy(),
  }) async {
    final entry = await (select(
      syncOutboxEntries,
    )..where((row) => row.operationId.equals(operationId))).getSingleOrNull();
    if (entry == null) {
      return null;
    }

    final state = policy.isPermanentFailure(entry.attemptCount)
        ? OutboxState.permanentFailure
        : OutboxState.retryableFailure;
    final nextAttemptAt = state == OutboxState.retryableFailure
        ? now.toUtc().add(policy.delayForAttempt(entry.attemptCount))
        : null;

    await (update(
      syncOutboxEntries,
    )..where((row) => row.operationId.equals(operationId))).write(
      SyncOutboxEntriesCompanion(
        status: Value(state.databaseValue),
        nextAttemptAt: Value(nextAttemptAt),
        lastError: Value(error),
        updatedAt: Value(now.toUtc()),
      ),
    );
    return state;
  }

  Future<int> recoverStaleProcessing({
    required DateTime staleBefore,
    required DateTime now,
  }) {
    return (update(syncOutboxEntries)..where(
          (row) =>
              row.status.equals(OutboxState.processing.databaseValue) &
              row.updatedAt.isSmallerThanValue(staleBefore.toUtc()),
        ))
        .write(
          SyncOutboxEntriesCompanion(
            status: Value(OutboxState.pending.databaseValue),
            nextAttemptAt: Value(now.toUtc()),
            lastError: const Value('Recovered stale processing operation.'),
            updatedAt: Value(now.toUtc()),
          ),
        );
  }
}
