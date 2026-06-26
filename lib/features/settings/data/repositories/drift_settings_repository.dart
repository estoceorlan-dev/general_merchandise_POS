import '../../../../shared/models/business_context.dart';
import '../../domain/repositories/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository();

  @override
  Future<void> saveBranchSetting({
    required BusinessContext context,
    required String key,
    required Object? value,
  }) {
    throw UnimplementedError(
      'Add Drift settings tables before saving branch settings.',
    );
  }
}
