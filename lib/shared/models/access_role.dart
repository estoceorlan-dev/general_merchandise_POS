import 'permission.dart';

class AccessRole {
  const AccessRole({
    required this.id,
    required this.code,
    required this.name,
    required this.permissions,
  });

  final String id;
  final String code;
  final String name;
  final Set<AppPermission> permissions;
}
