import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database_config.dart';

final appDatabaseConfigProvider = Provider<AppDatabaseConfig>((ref) {
  return const AppDatabaseConfig();
});
