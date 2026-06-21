import 'package:flutter/material.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/metric_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < AppBreakpoints.compact
            ? AppSpacing.lg
            : AppSpacing.xxl;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.xxl,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Dashboard', style: theme.textTheme.headlineLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sales, inventory, branch activity, and sync health will surface here.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      MetricTile(
                        title: 'Today sales',
                        value: 'PHP 0.00',
                        detail: 'Waiting for POS transactions',
                        icon: Icons.payments_outlined,
                      ),
                      MetricTile(
                        title: 'Open carts',
                        value: '0',
                        detail: 'No active registers yet',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      MetricTile(
                        title: 'Low stock',
                        value: '0',
                        detail: 'Inventory schema pending',
                        icon: Icons.warning_amber_outlined,
                      ),
                      MetricTile(
                        title: 'Pending sync',
                        value: '0',
                        detail: 'Offline queue ready for Drift',
                        icon: Icons.cloud_sync_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System foundation',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'This dashboard is wired to the app shell, routing, theme tokens, Riverpod scope, and placeholder service providers. Real metrics can be connected through feature repositories without moving business rules into widgets.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
