class BusinessContext {
  const BusinessContext({
    required this.organizationId,
    required this.branchId,
    required this.actorUserId,
  });

  final String organizationId;
  final String branchId;
  final String actorUserId;
}
