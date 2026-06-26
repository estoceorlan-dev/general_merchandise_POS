import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/database/app_database.dart';
import 'package:jce_pos/core/database/database_health_check_service.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the complete version 1 schema on a fresh database', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();

    expect(
      rows.map((row) => row.read<String>('name')),
      containsAll(<String>[
        'app_users',
        'branches',
        'local_audit_logs',
        'local_metadata',
        'organizations',
        'permissions',
        'role_permissions',
        'roles',
        'sync_conflicts',
        'sync_cursors',
        'sync_outbox',
        'user_role_assignments',
      ]),
    );
    expect(database.schemaVersion, AppDatabase.currentSchemaVersion);
  });

  test('health check reports schema and foreign key status', () async {
    final result = await DatabaseHealthCheckService(database).check();

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.schemaVersion, 1);
    expect(result.valueOrNull?.foreignKeysEnabled, isTrue);
  });

  test('metadata values can be written, observed, and replaced', () async {
    final observed = <String?>[];
    final subscription = database.metadataDao
        .watchValue('active_branch')
        .listen(observed.add);

    await database.metadataDao.writeValue(
      key: 'active_branch',
      value: 'branch-a',
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    await database.metadataDao.writeValue(
      key: 'active_branch',
      value: 'branch-b',
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    expect(await database.metadataDao.readValue('active_branch'), 'branch-b');
    await pumpEventQueue();
    expect(observed, containsAllInOrder(<String?>['branch-a', 'branch-b']));

    await subscription.cancel();
  });

  test('foreign keys reject branch records without an organization', () async {
    final now = DateTime.utc(2026, 1, 1);

    await expectLater(
      database
          .into(database.branches)
          .insert(
            BranchesCompanion.insert(
              id: 'branch-1',
              organizationId: 'missing-org',
              code: 'MAIN',
              name: 'Main',
              createdAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
