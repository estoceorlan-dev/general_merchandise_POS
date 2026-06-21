import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_breakpoints.dart';
import '../constants/app_constants.dart';
import '../routing/app_navigation_item.dart';
import 'desktop_sidebar.dart';
import 'mobile_bottom_navigation.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= AppBreakpoints.desktopNavigation;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                DesktopSidebar(
                  items: appNavigationItems,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text(AppConstants.appName)),
          body: navigationShell,
          bottomNavigationBar: MobileBottomNavigation(
            items: appNavigationItems,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          ),
        );
      },
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
