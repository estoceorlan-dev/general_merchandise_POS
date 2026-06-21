import 'package:flutter/material.dart';

import 'app_route.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final AppRoute route;
  final IconData icon;
  final IconData selectedIcon;

  String get label => route.label;
}

const appNavigationItems = <AppNavigationItem>[
  AppNavigationItem(
    route: AppRoute.dashboard,
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  AppNavigationItem(
    route: AppRoute.pos,
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
  ),
  AppNavigationItem(
    route: AppRoute.products,
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  AppNavigationItem(
    route: AppRoute.inventory,
    icon: Icons.warehouse_outlined,
    selectedIcon: Icons.warehouse,
  ),
  AppNavigationItem(
    route: AppRoute.transfers,
    icon: Icons.sync_alt_outlined,
    selectedIcon: Icons.sync_alt,
  ),
  AppNavigationItem(
    route: AppRoute.purchases,
    icon: Icons.shopping_cart_checkout_outlined,
    selectedIcon: Icons.shopping_cart_checkout,
  ),
  AppNavigationItem(
    route: AppRoute.reports,
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
  ),
  AppNavigationItem(
    route: AppRoute.logs,
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
  ),
  AppNavigationItem(
    route: AppRoute.users,
    icon: Icons.group_outlined,
    selectedIcon: Icons.group,
  ),
  AppNavigationItem(
    route: AppRoute.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];
