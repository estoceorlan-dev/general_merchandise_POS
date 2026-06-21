import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class TransfersPage extends StatelessWidget {
  const TransfersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Transfers',
      subtitle: 'Move merchandise between branches with approval tracking.',
      icon: Icons.sync_alt_outlined,
      highlights: [
        'Source and destination branch transfer workflow.',
        'Role-aware approval boundary for managers and admins.',
        'Audit trail for sent, received, adjusted, and cancelled transfers.',
      ],
    );
  }
}
