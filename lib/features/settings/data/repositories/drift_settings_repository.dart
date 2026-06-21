import '../../domain/repositories/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository();

  @override
  Future<void> saveBranchSetting(String key, Object? value) {
    throw UnimplementedError(
      'Add Drift settings tables before saving branch settings.',
    );
  }
}
