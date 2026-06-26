import '../config/app_config.dart';

abstract interface class AppInitializationService {
  Future<void> initialize(AppConfig config);
}
