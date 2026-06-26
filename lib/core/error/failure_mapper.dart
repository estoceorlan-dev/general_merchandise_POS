import 'dart:async';

import 'failure.dart';
import 'failures.dart';

abstract final class FailureMapper {
  static Failure fromException(Object error, StackTrace stackTrace) {
    if (error is Failure) {
      return error;
    }
    if (error is FormatException || error is ArgumentError) {
      return ValidationFailure(
        'The supplied value is invalid.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (error is TimeoutException) {
      return NetworkFailure(
        'The operation timed out.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return UnexpectedFailure(
      'An unexpected error occurred.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
