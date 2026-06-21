enum UserRole { owner, admin, manager, cashier, inventoryClerk, auditor }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.owner => 'Owner',
    UserRole.admin => 'Admin',
    UserRole.manager => 'Manager',
    UserRole.cashier => 'Cashier',
    UserRole.inventoryClerk => 'Inventory Clerk',
    UserRole.auditor => 'Auditor',
  };
}
