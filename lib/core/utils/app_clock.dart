import 'package:flutter_riverpod/flutter_riverpod.dart';

final appClockProvider = Provider<AppClock>((ref) {
  return const SystemAppClock();
});

abstract interface class AppClock {
  DateTime nowUtc();
}

final class SystemAppClock implements AppClock {
  const SystemAppClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

final class FixedAppClock implements AppClock {
  const FixedAppClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value.toUtc();
}
