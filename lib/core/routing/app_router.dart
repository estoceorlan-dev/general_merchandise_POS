import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_placeholder_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/logs/presentation/pages/logs_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/purchases/presentation/pages/purchases_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transfers/presentation/pages/transfers_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../widgets/app_navigation_shell.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.dashboard.path,
    routes: [
      GoRoute(
        path: AppRoute.auth.path,
        name: AppRoute.auth.routeName,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AuthPlaceholderPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          _branch(AppRoute.dashboard, const DashboardPage()),
          _branch(AppRoute.pos, const PosPage()),
          _branch(AppRoute.products, const ProductsPage()),
          _branch(AppRoute.inventory, const InventoryPage()),
          _branch(AppRoute.transfers, const TransfersPage()),
          _branch(AppRoute.purchases, const PurchasesPage()),
          _branch(AppRoute.reports, const ReportsPage()),
          _branch(AppRoute.logs, const LogsPage()),
          _branch(AppRoute.users, const UsersPage()),
          _branch(AppRoute.settings, const SettingsPage()),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(AppRoute route, Widget child) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: route.path,
        name: route.routeName,
        pageBuilder: (context, state) =>
            NoTransitionPage<void>(key: state.pageKey, child: child),
      ),
    ],
  );
}
