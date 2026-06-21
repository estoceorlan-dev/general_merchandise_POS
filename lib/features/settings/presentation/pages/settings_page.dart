import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Settings',
      subtitle:
          'Branch settings, register preferences, taxes, and integrations.',
      icon: Icons.settings_outlined,
      highlights: [
        'Settings repository boundary for local and backend persistence.',
        'Future Firebase, storage, sync, and branch configuration panels.',
        'Permission-gated admin controls for production deployment.',
      ],
    );
  }
}
