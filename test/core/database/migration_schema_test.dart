import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/database/app_database.dart';

import 'generated_migrations/schema.dart';

void main() {
  test('current schema matches the generated version 1 snapshot', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await database.validateDatabaseSchema();

    await database.close();
  });

  test(
    'released version 1 schema opens and validates without data loss',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);
      schema.rawDatabase.execute(
        'INSERT INTO local_metadata (`key`, `value`, `updated_at`) '
        "VALUES ('preserved', 'yes', '1970-01-01T00:00:00.000Z')",
      );

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 1);

      expect(await database.metadataDao.readValue('preserved'), 'yes');

      await database.close();
      schema.close();
    },
  );
}
