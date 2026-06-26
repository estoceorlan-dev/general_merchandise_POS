import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_environment.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromDartDefines();
});

class AppConfig {
  static const defaultFirebaseFunctionsRegion = 'asia-southeast1';

  const AppConfig({
    required this.environment,
    required this.enableDemoAuth,
    required this.enableDiagnostics,
    this.accessProfileFunctionName = 'getMyAccessProfile',
    this.deviceRegistrationFunctionName = 'registerDevice',
    this.updateBranchNameFunctionName = 'updateBranchName',
    this.adminBootstrapFunctionName = 'bootstrapTemporaryAdmin',
    this.apiBaseUri,
    this.demoBranchId,
    this.firebaseFunctionsRegion,
  });

  factory AppConfig.fromDartDefines() {
    const environmentValue = String.fromEnvironment(
      'JCE_ENV',
      defaultValue: 'development',
    );
    const apiBaseUrl = String.fromEnvironment('JCE_API_BASE_URL');
    const demoAuthValue = String.fromEnvironment('JCE_ENABLE_DEMO_AUTH');
    const diagnosticsValue = String.fromEnvironment('JCE_ENABLE_DIAGNOSTICS');
    const demoBranchIdValue = String.fromEnvironment('JCE_DEMO_BRANCH_ID');
    const functionsRegion = String.fromEnvironment(
      'JCE_FIREBASE_FUNCTIONS_REGION',
      defaultValue: defaultFirebaseFunctionsRegion,
    );
    const accessProfileFunction = String.fromEnvironment(
      'JCE_ACCESS_PROFILE_FUNCTION',
      defaultValue: 'getMyAccessProfile',
    );
    const deviceRegistrationFunction = String.fromEnvironment(
      'JCE_DEVICE_REGISTRATION_FUNCTION',
      defaultValue: 'registerDevice',
    );
    const updateBranchNameFunction = String.fromEnvironment(
      'JCE_UPDATE_BRANCH_NAME_FUNCTION',
      defaultValue: 'updateBranchName',
    );
    const adminBootstrapFunction = String.fromEnvironment(
      'JCE_ADMIN_BOOTSTRAP_FUNCTION',
      defaultValue: 'bootstrapTemporaryAdmin',
    );

    return AppConfig.fromValues(
      environment: environmentValue,
      apiBaseUrl: apiBaseUrl,
      enableDemoAuth: demoAuthValue,
      enableDiagnostics: diagnosticsValue,
      demoBranchId: demoBranchIdValue,
      firebaseFunctionsRegion: functionsRegion,
      accessProfileFunctionName: accessProfileFunction,
      deviceRegistrationFunctionName: deviceRegistrationFunction,
      updateBranchNameFunctionName: updateBranchNameFunction,
      adminBootstrapFunctionName: adminBootstrapFunction,
    );
  }

  factory AppConfig.fromValues({
    required String environment,
    String? apiBaseUrl,
    String? enableDemoAuth,
    String? enableDiagnostics,
    String? demoBranchId,
    String? firebaseFunctionsRegion,
    String accessProfileFunctionName = 'getMyAccessProfile',
    String deviceRegistrationFunctionName = 'registerDevice',
    String updateBranchNameFunctionName = 'updateBranchName',
    String adminBootstrapFunctionName = 'bootstrapTemporaryAdmin',
  }) {
    final parsedEnvironment = AppEnvironment.parse(environment);
    final parsedApiBaseUri = _parseAbsoluteUri(apiBaseUrl);
    final parsedEnableDemoAuth = _parseOptionalBool(
      enableDemoAuth,
      fallback: false,
      key: 'JCE_ENABLE_DEMO_AUTH',
    );
    final parsedEnableDiagnostics = _parseOptionalBool(
      enableDiagnostics,
      fallback: !parsedEnvironment.isProduction,
      key: 'JCE_ENABLE_DIAGNOSTICS',
    );
    final normalizedDemoBranchId = _normalizeOptional(demoBranchId);
    final normalizedFunctionsRegion =
        _normalizeOptional(firebaseFunctionsRegion) ??
        defaultFirebaseFunctionsRegion;
    final normalizedAccessProfileFunction = _requireValue(
      accessProfileFunctionName,
      key: 'JCE_ACCESS_PROFILE_FUNCTION',
    );
    final normalizedDeviceRegistrationFunction = _requireValue(
      deviceRegistrationFunctionName,
      key: 'JCE_DEVICE_REGISTRATION_FUNCTION',
    );
    final normalizedUpdateBranchNameFunction = _requireValue(
      updateBranchNameFunctionName,
      key: 'JCE_UPDATE_BRANCH_NAME_FUNCTION',
    );
    final normalizedAdminBootstrapFunction = _requireValue(
      adminBootstrapFunctionName,
      key: 'JCE_ADMIN_BOOTSTRAP_FUNCTION',
    );

    if (parsedEnableDemoAuth && normalizedDemoBranchId == null) {
      throw const FormatException(
        'JCE_DEMO_BRANCH_ID is required when demo authentication is enabled.',
      );
    }
    if (parsedEnableDemoAuth &&
        parsedEnvironment != AppEnvironment.development) {
      throw const FormatException(
        'Demo authentication can only be enabled in development.',
      );
    }

    return AppConfig(
      environment: parsedEnvironment,
      apiBaseUri: parsedApiBaseUri,
      enableDemoAuth: parsedEnableDemoAuth,
      enableDiagnostics: parsedEnableDiagnostics,
      demoBranchId: normalizedDemoBranchId,
      firebaseFunctionsRegion: normalizedFunctionsRegion,
      accessProfileFunctionName: normalizedAccessProfileFunction,
      deviceRegistrationFunctionName: normalizedDeviceRegistrationFunction,
      updateBranchNameFunctionName: normalizedUpdateBranchNameFunction,
      adminBootstrapFunctionName: normalizedAdminBootstrapFunction,
    );
  }

  final AppEnvironment environment;
  final Uri? apiBaseUri;
  final bool enableDemoAuth;
  final bool enableDiagnostics;
  final String? demoBranchId;
  final String? firebaseFunctionsRegion;
  final String accessProfileFunctionName;
  final String deviceRegistrationFunctionName;
  final String updateBranchNameFunctionName;
  final String adminBootstrapFunctionName;

  static Uri? _parseAbsoluteUri(String? value) {
    final normalized = _normalizeOptional(value);
    if (normalized == null) {
      return null;
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException(
        'JCE_API_BASE_URL must be an absolute URL when provided.',
      );
    }
    return uri;
  }

  static bool _parseOptionalBool(
    String? value, {
    required bool fallback,
    required String key,
  }) {
    final normalized = _normalizeOptional(value)?.toLowerCase();
    if (normalized == null) {
      return fallback;
    }

    return switch (normalized) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => throw FormatException('$key must be true or false.'),
    };
  }

  static String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static String _requireValue(String value, {required String key}) {
    final normalized = _normalizeOptional(value);
    if (normalized == null) {
      throw FormatException('$key cannot be empty.');
    }
    return normalized;
  }
}
