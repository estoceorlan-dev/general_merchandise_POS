import 'package:drift/drift.dart';

import '../constants/app_constants.dart';

class AppDatabaseConfig {
  const AppDatabaseConfig({
    this.executor,
    this.name = AppConstants.localDatabaseName,
    this.schemaVersion = 1,
  });

  final QueryExecutor? executor;
  final String name;
  final int schemaVersion;
}
