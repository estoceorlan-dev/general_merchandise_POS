import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/local_metadata_table.dart';

part 'metadata_dao.g.dart';

@DriftAccessor(tables: [LocalMetadata])
class MetadataDao extends DatabaseAccessor<AppDatabase>
    with _$MetadataDaoMixin {
  MetadataDao(super.attachedDatabase);

  Future<String?> readValue(String key) async {
    final query = select(localMetadata)
      ..where((row) => row.key.equals(key))
      ..limit(1);
    return (await query.getSingleOrNull())?.value;
  }

  Stream<String?> watchValue(String key) {
    final query = select(localMetadata)
      ..where((row) => row.key.equals(key))
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<void> writeValue({
    required String key,
    required String value,
    required DateTime updatedAt,
  }) {
    return into(localMetadata).insertOnConflictUpdate(
      LocalMetadataCompanion.insert(
        key: key,
        value: value,
        updatedAt: updatedAt.toUtc(),
      ),
    );
  }

  Future<int> deleteValue(String key) {
    return (delete(localMetadata)..where((row) => row.key.equals(key))).go();
  }
}
