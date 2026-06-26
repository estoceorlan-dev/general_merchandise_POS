import 'package:drift/drift.dart';

import 'permissions_table.dart';
import 'roles_table.dart';

class RolePermissions extends Table {
  TextColumn get roleId =>
      text().references(Roles, #id, onDelete: KeyAction.cascade)();
  TextColumn get permissionCode =>
      text().references(Permissions, #code, onDelete: KeyAction.cascade)();
  DateTimeColumn get grantedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {roleId, permissionCode};
}
