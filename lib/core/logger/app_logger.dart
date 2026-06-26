import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const DeveloperAppLogger();
});

abstract interface class AppLogger {
  void debug(String message, {String? scope});
  void info(String message, {String? scope});
  void warning(
    String message, {
    String? scope,
    Object? error,
    StackTrace? stackTrace,
  });
  void error(
    String message, {
    String? scope,
    Object? error,
    StackTrace? stackTrace,
  });
}

final class DeveloperAppLogger implements AppLogger {
  const DeveloperAppLogger();

  @override
  void debug(String message, {String? scope}) {
    _write(message, level: 500, scope: scope);
  }

  @override
  void info(String message, {String? scope}) {
    _write(message, level: 800, scope: scope);
  }

  @override
  void warning(
    String message, {
    String? scope,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write(
      message,
      level: 900,
      scope: scope,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(
    String message, {
    String? scope,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write(
      message,
      level: 1000,
      scope: scope,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _write(
    String message, {
    required int level,
    String? scope,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: scope == null ? 'jce_pos' : 'jce_pos.$scope',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
