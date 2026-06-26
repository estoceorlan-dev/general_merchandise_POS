enum UserAccountStatus {
  invited,
  active,
  suspended,
  disabled;

  static UserAccountStatus parse(String value) {
    return values.firstWhere(
      (status) => status.name == value.trim().toLowerCase(),
      orElse: () => UserAccountStatus.disabled,
    );
  }
}
