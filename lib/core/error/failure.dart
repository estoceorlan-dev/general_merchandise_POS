enum FailureType {
  validation,
  authentication,
  authorization,
  database,
  network,
  synchronization,
  conflict,
  unexpected,
}

abstract class Failure {
  const Failure(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  FailureType get type;

  @override
  String toString() => '$runtimeType($message)';
}
