class InventorySnapshot {
  const InventorySnapshot({
    required this.productId,
    required this.branchId,
    required this.onHand,
    required this.reserved,
    required this.reorderPoint,
  });

  final String productId;
  final String branchId;
  final num onHand;
  final num reserved;
  final num reorderPoint;
}
