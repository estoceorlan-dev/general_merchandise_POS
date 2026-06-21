enum AppRoute {
  auth,
  dashboard,
  pos,
  products,
  inventory,
  transfers,
  purchases,
  reports,
  logs,
  users,
  settings,
}

extension AppRouteInfo on AppRoute {
  String get routeName => switch (this) {
    AppRoute.auth => 'auth',
    AppRoute.dashboard => 'dashboard',
    AppRoute.pos => 'pos',
    AppRoute.products => 'products',
    AppRoute.inventory => 'inventory',
    AppRoute.transfers => 'transfers',
    AppRoute.purchases => 'purchases',
    AppRoute.reports => 'reports',
    AppRoute.logs => 'logs',
    AppRoute.users => 'users',
    AppRoute.settings => 'settings',
  };

  String get path => switch (this) {
    AppRoute.auth => '/auth',
    AppRoute.dashboard => '/',
    AppRoute.pos => '/pos',
    AppRoute.products => '/products',
    AppRoute.inventory => '/inventory',
    AppRoute.transfers => '/transfers',
    AppRoute.purchases => '/purchases',
    AppRoute.reports => '/reports',
    AppRoute.logs => '/logs',
    AppRoute.users => '/users',
    AppRoute.settings => '/settings',
  };

  String get label => switch (this) {
    AppRoute.auth => 'Auth',
    AppRoute.dashboard => 'Dashboard',
    AppRoute.pos => 'POS',
    AppRoute.products => 'Products',
    AppRoute.inventory => 'Inventory',
    AppRoute.transfers => 'Transfers',
    AppRoute.purchases => 'Purchases',
    AppRoute.reports => 'Reports',
    AppRoute.logs => 'Logs',
    AppRoute.users => 'Users',
    AppRoute.settings => 'Settings',
  };
}
