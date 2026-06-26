import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_constants.dart';
import '../routing/app_navigation_item.dart';
import '../routing/app_route.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'desktop_sidebar.dart';
import 'mobile_bottom_navigation.dart';
import 'sidebar/sidebar_branch_badge.dart';

class AppNavigationShell extends ConsumerWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final navigationItems = navigationItemsForSession(session);
    final selectedRoute =
        appNavigationItems[navigationShell.currentIndex].route;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= AppBreakpoints.desktopNavigation;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                DesktopSidebar(
                  items: navigationItems,
                  selectedRoute: selectedRoute,
                  session: session,
                  onDestinationSelected: _goToItem,
                  onSettingsSelected: () => _goToRoute(AppRoute.settings),
                  onBranchSelected: (organizationId, branchId) =>
                      _selectBranch(ref, organizationId, branchId),
                  onRefreshAccess: () => _refreshAccess(ref),
                  onLogout: () => _logout(ref),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: _ShellTopBar(
                          title: selectedRoute.label,
                          session: session,
                          onBranchSelected: (organizationId, branchId) =>
                              _selectBranch(ref, organizationId, branchId),
                          onRefreshAccess: () => _refreshAccess(ref),
                        ),
                      ),
                      Expanded(child: navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(selectedRoute.label),
            actions: [
              IconButton(
                tooltip: 'Refresh access',
                onPressed: () => _refreshAccess(ref),
                icon: const Icon(Icons.refresh),
              ),
              SidebarBranchBadge(
                session: session,
                compact: true,
                onSelected: (organizationId, branchId) =>
                    _selectBranch(ref, organizationId, branchId),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: navigationShell,
          bottomNavigationBar: MobileBottomNavigation(
            items: navigationItems,
            selectedRoute: selectedRoute,
            onDestinationSelected: _goToItem,
          ),
        );
      },
    );
  }

  void _goToItem(AppNavigationItem item) {
    _goToRoute(item.route);
  }

  void _goToRoute(AppRoute route) {
    final index = appNavigationItems.indexWhere(
      (navigationItem) => navigationItem.route == route,
    );

    if (index < 0) {
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _logout(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
  }

  Future<void> _selectBranch(
    WidgetRef ref,
    String organizationId,
    String branchId,
  ) {
    return ref
        .read(authControllerProvider.notifier)
        .selectActiveBranch(organizationId: organizationId, branchId: branchId);
  }

  Future<void> _refreshAccess(WidgetRef ref) {
    return ref.read(authControllerProvider.notifier).refreshAccess();
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({
    required this.title,
    required this.session,
    required this.onBranchSelected,
    required this.onRefreshAccess,
  });

  final String title;
  final AuthSession session;
  final BranchSelectionCallback onBranchSelected;
  final VoidCallback onRefreshAccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.slate50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appName, style: theme.textTheme.labelMedium),
              Text(title, style: theme.textTheme.titleLarge),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh access',
            onPressed: onRefreshAccess,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: AppSpacing.sm),
          SidebarBranchBadge(
            session: session,
            compact: true,
            onSelected: onBranchSelected,
          ),
        ],
      ),
    );
  }
}
