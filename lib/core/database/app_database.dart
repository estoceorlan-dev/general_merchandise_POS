import 'package:drift/drift.dart';

import 'app_database_config.dart';
import 'daos/audit_log_dao.dart';
import 'daos/metadata_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/sync_conflict_dao.dart';
import 'daos/sync_cursor_dao.dart';
import 'database_connection.dart';
import 'models/outbox_state.dart';
import 'tables/app_users_table.dart';
import 'tables/branches_table.dart';
import 'tables/local_audit_logs_table.dart';
import 'tables/local_metadata_table.dart';
import 'tables/organizations_table.dart';
import 'tables/permissions_table.dart';
import 'tables/role_permissions_table.dart';
import 'tables/roles_table.dart';
import 'tables/sync_conflicts_table.dart';
import 'tables/sync_cursors_table.dart';
import 'tables/sync_outbox_table.dart';
import 'tables/user_role_assignments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalMetadata,
    SyncOutboxEntries,
    SyncCursors,
    SyncConflicts,
    LocalAuditLogs,
    Organizations,
    Branches,
    AppUsers,
    Roles,
    Permissions,
    RolePermissions,
    UserRoleAssignments,
  ],
  daos: [MetadataDao, OutboxDao, SyncCursorDao, SyncConflictDao, AuditLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(AppDatabaseConfig config)
    : super(config.executor ?? openDatabaseConnection(config.name));

  AppDatabase.forTesting(super.executor);

  static const int currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      await transaction(() async {
        for (var version = from + 1; version <= to; version++) {
          await _migrateTo(migrator, version);
        }
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (!details.wasCreated) {
        await customUpdate(
          'UPDATE sync_outbox '
          'SET status = ?, next_attempt_at = NULL, '
          'last_error = COALESCE(last_error, ?) '
          'WHERE status = ?',
          variables: [
            Variable<String>(OutboxState.pending.databaseValue),
            const Variable<String>(
              'Recovered processing operation after application restart.',
            ),
            Variable<String>(OutboxState.processing.databaseValue),
          ],
          updates: {syncOutboxEntries},
        );
      }
    },
  );

  Future<void> _migrateTo(Migrator migrator, int version) async {
    switch (version) {
      case 1:
        await migrator.createAll();
      default:
        throw StateError('Missing migration for schema version $version.');
    }
  }
}
