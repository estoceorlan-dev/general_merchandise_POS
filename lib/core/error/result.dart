import 'failure.dart';

sealed class Result<S, F extends Failure> {
  const Result();

  const factory Result.success(S value) = SuccessResult<S, F>;
  const factory Result.failure(F failure) = FailureResult<S, F>;

  bool get isSuccess => this is SuccessResult<S, F>;
  bool get isFailure => this is FailureResult<S, F>;

  S? get valueOrNull => switch (this) {
    SuccessResult<S, F>(:final value) => value,
    FailureResult<S, F>() => null,
  };

  F? get failureOrNull => switch (this) {
    SuccessResult<S, F>() => null,
    FailureResult<S, F>(:final failure) => failure,
  };

  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) {
    return switch (this) {
      SuccessResult<S, F>(:final value) => onSuccess(value),
      FailureResult<S, F>(:final failure) => onFailure(failure),
    };
  }

  Result<T, F> map<T>(T Function(S value) transform) {
    return switch (this) {
      SuccessResult<S, F>(:final value) => Result<T, F>.success(
        transform(value),
      ),
      FailureResult<S, F>(:final failure) => Result<T, F>.failure(failure),
    };
  }
}

final class SuccessResult<S, F extends Failure> extends Result<S, F> {
  const SuccessResult(this.value);

  final S value;
}

final class FailureResult<S, F extends Failure> extends Result<S, F> {
  const FailureResult(this.failure);

  final F failure;
}
