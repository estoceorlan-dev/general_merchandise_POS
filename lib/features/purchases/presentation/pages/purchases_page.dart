import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Purchases',
      subtitle: 'Purchase orders, receiving, suppliers, and landed costs.',
      icon: Icons.shopping_cart_checkout_outlined,
      highlights: [
        'Purchase order repository boundary for future supplier workflows.',
        'Receiving flow prepared for inventory updates and audit logs.',
        'Offline drafts that can sync when a branch reconnects.',
      ],
    );
  }
}
