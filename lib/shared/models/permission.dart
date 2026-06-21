import 'user_role.dart';

enum AppPermission {
  viewDashboard,
  processSales,
  manageProducts,
  manageInventory,
  approveTransfers,
  createPurchases,
  viewReports,
  viewAuditLogs,
  manageUsers,
  manageSettings,
}

const rolePermissions = <UserRole, Set<AppPermission>>{
  UserRole.owner: {...AppPermission.values},
  UserRole.admin: {...AppPermission.values},
  UserRole.manager: {
    AppPermission.viewDashboard,
    AppPermission.processSales,
    AppPermission.manageProducts,
    AppPermission.manageInventory,
    AppPermission.approveTransfers,
    AppPermission.createPurchases,
    AppPermission.viewReports,
    AppPermission.viewAuditLogs,
  },
  UserRole.cashier: {AppPermission.viewDashboard, AppPermission.processSales},
  UserRole.inventoryClerk: {
    AppPermission.viewDashboard,
    AppPermission.manageProducts,
    AppPermission.manageInventory,
    AppPermission.approveTransfers,
    AppPermission.createPurchases,
  },
  UserRole.auditor: {
    AppPermission.viewDashboard,
    AppPermission.viewReports,
    AppPermission.viewAuditLogs,
  },
};

extension RolePermissionChecks on UserRole {
  bool can(AppPermission permission) {
    return rolePermissions[this]?.contains(permission) ?? false;
  }
}
