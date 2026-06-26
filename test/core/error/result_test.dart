import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/error/failures.dart';
import 'package:jce_pos/core/error/result.dart';

void main() {
  group('Result', () {
    test('exposes and transforms successful values', () {
      const result = Result<int, ValidationFailure>.success(21);
      final transformed = result.map((value) => value * 2);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 21);
      expect(transformed.valueOrNull, 42);
      expect(transformed.failureOrNull, isNull);
    });

    test('preserves typed failures', () {
      const failure = ValidationFailure('Invalid product name.');
      const result = Result<int, ValidationFailure>.failure(failure);

      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
      expect(
        result.fold(
          onSuccess: (value) => '$value',
          onFailure: (error) => error.message,
        ),
        'Invalid product name.',
      );
    });
  });
}
