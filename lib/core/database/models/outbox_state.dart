enum OutboxState {
  pending('pending'),
  processing('processing'),
  succeeded('succeeded'),
  retryableFailure('retryable_failure'),
  permanentFailure('permanent_failure');

  const OutboxState(this.databaseValue);

  final String databaseValue;

  static OutboxState fromDatabase(String value) {
    return OutboxState.values.firstWhere(
      (state) => state.databaseValue == value,
      orElse: () => throw ArgumentError.value(value, 'value'),
    );
  }
}
