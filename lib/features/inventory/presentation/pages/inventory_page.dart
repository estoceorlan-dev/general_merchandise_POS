import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Inventory',
      subtitle:
          'Branch stock levels, adjustments, counts, and reorder signals.',
      icon: Icons.warehouse_outlined,
      highlights: [
        'Offline-first stock snapshots by product and branch.',
        'Adjustment queue prepared for Drift and PostgreSQL sync.',
        'Low-stock and discrepancy views for daily operations.',
      ],
    );
  }
}
