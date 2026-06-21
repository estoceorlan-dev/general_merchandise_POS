class SaleSummary {
  const SaleSummary({
    required this.id,
    required this.branchId,
    required this.cashierId,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String branchId;
  final String cashierId;
  final num total;
  final DateTime createdAt;
}
