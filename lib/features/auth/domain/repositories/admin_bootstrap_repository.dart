class AdminBootstrapResult {
  const AdminBootstrapResult({
    required this.appUserId,
    required this.firebaseUid,
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String appUserId;
  final String firebaseUid;
  final String email;
  final String password;
  final String displayName;
}

abstract interface class AdminBootstrapRepository {
  Future<AdminBootstrapResult> createTemporaryAdminAccount();
}

class AdminBootstrapException implements Exception {
  const AdminBootstrapException(this.message);

  final String message;
}
