import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Reports',
      subtitle:
          'Sales, inventory, purchasing, and branch performance analytics.',
      icon: Icons.bar_chart_outlined,
      highlights: [
        'Dashboard metrics can be hydrated from reporting repositories.',
        'Branch and date filters ready for analytics dashboards.',
        'Export boundaries can be added without changing page routing.',
      ],
    );
  }
}
