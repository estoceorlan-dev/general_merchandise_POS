import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/database/app_database.dart';
import 'package:jce_pos/core/services/audit_log_service.dart';
import 'package:jce_pos/shared/models/audit_log_entry.dart';

void main() {
  test('persists audit log entries in Drift', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final service = LocalAuditLogQueueService(database.auditLogDao);
    final entry = AuditLogEntry(
      id: 'audit-1',
      operationId: 'operation-1',
      organizationId: 'org-1',
      actorUserId: 'user-1',
      branchId: 'branch-1',
      actionType: AuditActionType.update,
      entityName: 'product',
      entityId: 'product-1',
      metadata: const {'field': 'name'},
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final result = await service.record(entry);
    final persisted = await database.auditLogDao.watchEntries().first;

    expect(result.isSuccess, isTrue);
    expect(persisted, hasLength(1));
    expect(persisted.single.id, entry.id);
    expect(persisted.single.metadata, entry.metadata);

    await database.close();
  });
}
