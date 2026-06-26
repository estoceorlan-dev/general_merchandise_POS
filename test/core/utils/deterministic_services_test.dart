import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/utils/app_clock.dart';
import 'package:jce_pos/core/utils/id_generator.dart';

void main() {
  test('fixed clock returns a deterministic UTC timestamp', () {
    final clock = FixedAppClock(DateTime.parse('2026-06-24T12:30:00+08:00'));

    expect(clock.nowUtc(), DateTime.parse('2026-06-24T04:30:00Z'));
  });

  test('fixed ID generator returns a deterministic ID', () {
    const generator = FixedIdGenerator('operation-id');

    expect(generator.newId(), 'operation-id');
  });
}
