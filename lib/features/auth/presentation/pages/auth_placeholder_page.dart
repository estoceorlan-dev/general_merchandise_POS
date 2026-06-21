import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class AuthPlaceholderPage extends StatelessWidget {
  const AuthPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Authentication',
      subtitle: 'Firebase Authentication entry point for staff access.',
      icon: Icons.lock_outline,
      highlights: [
        'Email, password, and future SSO flows through Firebase Auth.',
        'Role and branch assignment resolved after sign-in.',
        'Auth state exposed through repository and Riverpod providers.',
      ],
    );
  }
}
