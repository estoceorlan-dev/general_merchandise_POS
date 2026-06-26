import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_conflicts_table.dart';

part 'sync_conflict_dao.g.dart';

@DriftAccessor(tables: [SyncConflicts])
class SyncConflictDao extends DatabaseAccessor<AppDatabase>
    with _$SyncConflictDaoMixin {
  SyncConflictDao(super.attachedDatabase);

  Future<void> add(SyncConflictsCompanion conflict) {
    return into(syncConflicts).insert(conflict);
  }

  Stream<List<SyncConflict>> watchUnresolved() {
    final query = select(syncConflicts)
      ..where((row) => row.resolvedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    return query.watch();
  }

  Future<int> resolve({
    required String id,
    required String resolutionStatus,
    required DateTime resolvedAt,
  }) {
    return (update(syncConflicts)..where((row) => row.id.equals(id))).write(
      SyncConflictsCompanion(
        resolutionStatus: Value(resolutionStatus),
        resolvedAt: Value(resolvedAt.toUtc()),
      ),
    );
  }
}
