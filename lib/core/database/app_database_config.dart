import 'package:drift/drift.dart';

import '../constants/app_constants.dart';

class AppDatabaseConfig {
  const AppDatabaseConfig({
    this.executor,
    this.name = AppConstants.localDatabaseName,
  });

  final QueryExecutor? executor;
  final String name;
}
