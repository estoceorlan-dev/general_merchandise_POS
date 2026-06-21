import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_placeholder_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Users',
      subtitle: 'Staff accounts, roles, branches, and permissions.',
      icon: Icons.group_outlined,
      highlights: [
        'Role model and permission map prepared for access control.',
        'Firebase Auth user state can map into app users and branches.',
        'Admin workflows for invitations, lockouts, and role changes.',
      ],
    );
  }
}
