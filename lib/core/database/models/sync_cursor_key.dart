class SyncCursorKey {
  const SyncCursorKey({
    required this.scope,
    this.organizationId,
    this.branchId,
  });

  final String scope;
  final String? organizationId;
  final String? branchId;

  String get value => [scope, organizationId ?? '_', branchId ?? '_'].join(':');
}
