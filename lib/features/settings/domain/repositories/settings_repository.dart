abstract interface class SettingsRepository {
  Future<void> saveBranchSetting(String key, Object? value);
}
