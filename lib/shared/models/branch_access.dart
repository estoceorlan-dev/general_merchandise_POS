import 'access_role.dart';
import 'branch.dart';
import 'permission.dart';

class BranchAccess {
  const BranchAccess({required this.branch, required this.roles});

  final Branch branch;
  final List<AccessRole> roles;

  Set<AppPermission> get permissions => {
    for (final role in roles) ...role.permissions,
  };
}
