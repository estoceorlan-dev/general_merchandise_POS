import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'POS',
      subtitle: 'Fast cashier workspace for sales processing.',
      icon: Icons.point_of_sale_outlined,
      highlights: [
        'Register, cart, discounts, payment, and receipt flow.',
        'Offline transaction queue through Drift before backend sync.',
        'Audit entries for sale creation, voids, refunds, and overrides.',
      ],
    );
  }
}
