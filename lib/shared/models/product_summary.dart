class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.isActive,
  });

  final String id;
  final String sku;
  final String name;
  final String category;
  final num price;
  final bool isActive;
}
