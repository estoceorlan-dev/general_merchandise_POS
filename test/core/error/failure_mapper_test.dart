import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/error/failure.dart';
import 'package:jce_pos/core/error/failure_mapper.dart';
import 'package:jce_pos/core/error/failures.dart';

void main() {
  group('FailureMapper', () {
    test('maps malformed values to validation failures', () {
      final failure = FailureMapper.fromException(
        const FormatException('invalid'),
        StackTrace.empty,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.type, FailureType.validation);
    });

    test('maps timeouts to network failures', () {
      final failure = FailureMapper.fromException(
        TimeoutException('slow'),
        StackTrace.empty,
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.type, FailureType.network);
    });

    test('maps unknown exceptions to unexpected failures', () {
      final failure = FailureMapper.fromException(
        StateError('unknown'),
        StackTrace.empty,
      );

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.type, FailureType.unexpected);
    });
  });
}
