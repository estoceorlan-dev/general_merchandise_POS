import 'package:drift/drift.dart';

import 'database_connection_unsupported.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart'
    as platform;

QueryExecutor openDatabaseConnection(String databaseName) {
  return platform.openDatabaseConnection(databaseName);
}
