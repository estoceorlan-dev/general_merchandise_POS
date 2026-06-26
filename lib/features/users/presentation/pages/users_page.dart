import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    if (session == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Access control',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Organizations, assigned branches, roles, and effective permissions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).refreshAccess(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh access'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final organization in session.user.organizations) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          organization.organization.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(label: Text(organization.status.name.toUpperCase())),
                    ],
                  ),
                  Text(
                    organization.organization.code,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final branch in organization.branches) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        branch.branch.id == session.activeBranchId
                            ? Icons.storefront
                            : Icons.storefront_outlined,
                      ),
                      title: Text(branch.branch.name),
                      subtitle: Text(
                        [
                          ...organization.organizationRoles,
                          ...branch.roles,
                        ].map((role) => role.name).toSet().join(', '),
                      ),
                      trailing: branch.branch.id == session.activeBranchId
                          ? const Chip(label: Text('ACTIVE'))
                          : null,
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final permission in organization.permissionsFor(
                          branch.branch.id,
                        ))
                          Chip(label: Text(permission.code)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
