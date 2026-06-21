import 'package:flutter_riverpod/flutter_riverpod.dart';

final backendEndpointConfigProvider = Provider<BackendEndpointConfig>((ref) {
  return const BackendEndpointConfig();
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
  Future<void> pushPendingChanges();
  Future<void> pullLatestChanges({String? branchId});
}

class DeferredBackendSyncService implements BackendSyncService {
  const DeferredBackendSyncService({required this.config});

  final BackendEndpointConfig config;

  @override
  Future<void> pullLatestChanges({String? branchId}) {
    throw UnimplementedError(
      'Configure a PostgreSQL-backed API before enabling remote sync.',
    );
  }

  @override
  Future<void> pushPendingChanges() {
    throw UnimplementedError(
      'Configure a PostgreSQL-backed API before enabling remote sync.',
    );
  }
}
