import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/app.dart';

void main() {
  testWidgets('JCE POS starts on the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JcePosApp()));
    await tester.pumpAndSettle();

    expect(find.text('JCE POS'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byIcon(Icons.point_of_sale_outlined), findsWidgets);
  });
}
