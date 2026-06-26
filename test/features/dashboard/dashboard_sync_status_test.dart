import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/database/app_database.dart';
import 'package:jce_pos/core/database/database_provider.dart';
import 'package:jce_pos/core/database/models/outbox_command.dart';
import 'package:jce_pos/core/widgets/metric_tile.dart';
import 'package:jce_pos/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  testWidgets('dashboard displays the live pending outbox count', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.outboxDao.enqueue(
      OutboxCommand(
        operationId: 'operation-1',
        organizationId: 'org-1',
        branchId: 'branch-1',
        commandType: 'test',
        aggregateType: 'test',
        aggregateId: 'aggregate-1',
        payload: const {'pending': true},
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: DashboardPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MetricTile, 'Pending sync'), findsOneWidget);
    expect(find.widgetWithText(MetricTile, '1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
