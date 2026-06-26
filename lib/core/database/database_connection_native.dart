import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

QueryExecutor openDatabaseConnection(String databaseName) {
  final connection = Future<DatabaseConnection>(() async {
    final directory = await getApplicationSupportDirectory();
    final databaseFile = File(path.join(directory.path, databaseName));
    final executor = NativeDatabase.createInBackground(databaseFile);
    return DatabaseConnection(executor);
  });

  return DatabaseConnection.delayed(connection);
}
