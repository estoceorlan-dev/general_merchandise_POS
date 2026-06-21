import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: SizedBox(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: colorScheme.primary, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(detail, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
