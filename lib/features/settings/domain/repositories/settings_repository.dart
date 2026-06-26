import '../../../../shared/models/business_context.dart';

abstract interface class SettingsRepository {
  Future<void> saveBranchSetting({
    required BusinessContext context,
    required String key,
    required Object? value,
  });
}
