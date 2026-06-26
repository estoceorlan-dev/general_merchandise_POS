import 'package:drift/drift.dart';

class LocalAuditLogs extends Table {
  @override
  String get tableName => 'local_audit_logs';

  TextColumn get id => text()();
  TextColumn get operationId => text().nullable()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get actorUserId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get actionType => text()();
  TextColumn get auditedEntityName => text().named('entity_name')();
  TextColumn get entityId => text()();
  TextColumn get metadataJson =>
      text().withDefault(const Constant<String>('{}'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
