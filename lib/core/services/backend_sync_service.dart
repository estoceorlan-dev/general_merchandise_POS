import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/business_context.dart';
import '../config/app_config.dart';

final backendEndpointConfigProvider = Provider<BackendEndpointConfig>((ref) {
  return BackendEndpointConfig(
    apiBaseUri: ref.watch(appConfigProvider).apiBaseUri,
  );
});

final backendSyncServiceProvider = Provider<BackendSyncService>((ref) {
  return DeferredBackendSyncService(
    config: ref.watch(backendEndpointConfigProvider),
  );
});

class BackendEndpointConfig {
  const BackendEndpointConfig({
    this.apiBaseUri,
    this.databaseEngine = 'postgresql',
  });

  final Uri? apiBaseUri;
  final String databaseEngine;
}

abstract interface class BackendSyncService {
  Future<void> pushPendingChanges({required BusinessContext context});
  Future<void> pullLatestChanges({required BusinessContext context});
}

class DeferredBackendSyncService implements BackendSyncService {
  const DeferredBackendSyncService({required this.config});

  final BackendEndpointConfig config;

  @override
  Future<void> pullLatestChanges({required BusinessContext context}) {
    throw UnimplementedError(
      'Configure a PostgreSQL-backed API before enabling remote sync.',
    );
  }

  @override
  Future<void> pushPendingChanges({required BusinessContext context}) {
    throw UnimplementedError(
      'Configure a PostgreSQL-backed API before enabling remote sync.',
    );
  }
}
