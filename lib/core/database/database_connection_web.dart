import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openDatabaseConnection(String databaseName) {
  final connection = WasmDatabase.open(
    databaseName: databaseName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  ).then((result) => result.resolvedExecutor);

  return DatabaseConnection.delayed(connection);
}
