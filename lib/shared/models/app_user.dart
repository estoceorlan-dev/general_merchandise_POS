import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.branchId,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String branchId;
}
