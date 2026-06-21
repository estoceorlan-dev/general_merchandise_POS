import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Products',
      subtitle: 'Product catalog, SKUs, pricing, categories, and barcodes.',
      icon: Icons.inventory_2_outlined,
      highlights: [
        'Repository-ready product model and sync boundary.',
        'Future Firebase Storage hooks for product photos and attachments.',
        'Clean UI surface for search, filters, variants, and pricing rules.',
      ],
    );
  }
}
