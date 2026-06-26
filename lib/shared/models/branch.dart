class Branch {
  const Branch({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    required this.timezone,
  });

  final String id;
  final String organizationId;
  final String code;
  final String name;
  final String timezone;
}
