import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../shared/models/audit_log_entry.dart' as model;
import '../app_database.dart';
import '../tables/local_audit_logs_table.dart';

part 'audit_log_dao.g.dart';

@DriftAccessor(tables: [LocalAuditLogs])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.attachedDatabase);

  Future<void> append(model.AuditLogEntry entry) {
    return into(localAuditLogs).insert(
      LocalAuditLogsCompanion.insert(
        id: entry.id,
        operationId: Value(entry.operationId),
        organizationId: Value(entry.organizationId),
        actorUserId: entry.actorUserId,
        branchId: Value(entry.branchId),
        deviceId: Value(entry.deviceId),
        actionType: entry.actionType.name,
        auditedEntityName: entry.entityName,
        entityId: entry.entityId,
        metadataJson: Value(jsonEncode(entry.metadata)),
        createdAt: entry.createdAt.toUtc(),
      ),
    );
  }

  Stream<List<model.AuditLogEntry>> watchEntries({
    String? organizationId,
    String? branchId,
  }) {
    final query = select(localAuditLogs);
    if (organizationId != null) {
      query.where((row) => row.organizationId.equals(organizationId));
    }
    if (branchId != null) {
      query.where((row) => row.branchId.equals(branchId));
    }
    query.orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map(
      (rows) => rows.map(_toModel).toList(growable: false),
    );
  }

  model.AuditLogEntry _toModel(LocalAuditLog row) {
    return model.AuditLogEntry(
      id: row.id,
      operationId: row.operationId,
      organizationId: row.organizationId,
      actorUserId: row.actorUserId,
      branchId: row.branchId,
      deviceId: row.deviceId,
      actionType: model.AuditActionType.values.byName(row.actionType),
      entityName: row.auditedEntityName,
      entityId: row.entityId,
      metadata: (jsonDecode(row.metadataJson) as Map<String, dynamic>)
          .cast<String, Object?>(),
      createdAt: row.createdAt.toUtc(),
    );
  }
}
