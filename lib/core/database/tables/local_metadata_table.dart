import 'package:drift/drift.dart';

class LocalMetadata extends Table {
  @override
  String get tableName => 'local_metadata';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
