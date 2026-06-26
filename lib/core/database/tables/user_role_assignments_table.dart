import 'package:drift/drift.dart';

import 'app_users_table.dart';
import 'branches_table.dart';
import 'organizations_table.dart';
import 'roles_table.dart';

class UserRoleAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #id, onDelete: KeyAction.restrict)();
  TextColumn get branchId => text().nullable().references(
    Branches,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get userId =>
      text().references(AppUsers, #id, onDelete: KeyAction.cascade)();
  TextColumn get roleId =>
      text().references(Roles, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get assignedAt => dateTime()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
