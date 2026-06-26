import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failure.dart';
import '../error/failures.dart';
import '../error/result.dart';
import 'app_database.dart';
import 'database_provider.dart';

class DatabaseHealth {
  const DatabaseHealth({
    required this.schemaVersion,
    required this.foreignKeysEnabled,
  });

  final int schemaVersion;
  final bool foreignKeysEnabled;
}

final databaseHealthCheckServiceProvider = Provider<DatabaseHealthCheckService>(
  (ref) {
    return DatabaseHealthCheckService(ref.watch(appDatabaseProvider));
  },
);

class DatabaseHealthCheckService {
  const DatabaseHealthCheckService(this._database);

  final AppDatabase _database;

  Future<Result<DatabaseHealth, Failure>> check() async {
    try {
      await _database.customSelect('SELECT 1').getSingle();
      final versionRow = await _database
          .customSelect('PRAGMA user_version')
          .getSingle();
      final foreignKeysRow = await _database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();

      return Result.success(
        DatabaseHealth(
          schemaVersion: versionRow.read<int>('user_version'),
          foreignKeysEnabled: foreignKeysRow.read<int>('foreign_keys') == 1,
        ),
      );
    } catch (error, stackTrace) {
      return Result.failure(
        DatabaseFailure(
          'The local database health check failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
