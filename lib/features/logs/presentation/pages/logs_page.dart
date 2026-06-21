import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Logs',
      subtitle: 'Audit logs for operational, security, and sync events.',
      icon: Icons.fact_check_outlined,
      highlights: [
        'Append-only audit log model prepared in shared models.',
        'Local queue service ready for Drift-backed persistence.',
        'Future filters by actor, branch, entity, and action type.',
      ],
    );
  }
}
