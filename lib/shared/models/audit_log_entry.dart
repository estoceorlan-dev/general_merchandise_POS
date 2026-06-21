enum AuditActionType { create, update, delete, login, sale, transfer, sync }

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.actorUserId,
    required this.branchId,
    required this.actionType,
    required this.entityName,
    required this.entityId,
    required this.createdAt,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String actorUserId;
  final String branchId;
  final AuditActionType actionType;
  final String entityName;
  final String entityId;
  final DateTime createdAt;
  final Map<String, Object?> metadata;
}
