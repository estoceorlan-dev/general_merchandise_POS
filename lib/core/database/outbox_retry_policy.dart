class OutboxRetryPolicy {
  const OutboxRetryPolicy({
    this.baseDelay = const Duration(seconds: 5),
    this.maximumDelay = const Duration(hours: 1),
    this.maximumAttempts = 10,
  }) : assert(maximumAttempts > 0);

  final Duration baseDelay;
  final Duration maximumDelay;
  final int maximumAttempts;

  Duration delayForAttempt(int attemptCount) {
    if (attemptCount <= 0) {
      return Duration.zero;
    }

    final exponent = (attemptCount - 1).clamp(0, 30);
    final multiplier = 1 << exponent;
    final delayMilliseconds = baseDelay.inMilliseconds * multiplier;

    return Duration(
      milliseconds: delayMilliseconds.clamp(0, maximumDelay.inMilliseconds),
    );
  }

  bool isPermanentFailure(int attemptCount) {
    return attemptCount >= maximumAttempts;
  }
}
