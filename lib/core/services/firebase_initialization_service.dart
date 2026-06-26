import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import '../startup/app_initialization_service.dart';

final firebaseInitializationServiceProvider =
    Provider<AppInitializationService>((ref) {
      return const FirebaseInitializationService();
    });

class FirebaseInitializationService implements AppInitializationService {
  const FirebaseInitializationService();

  @override
  Future<void> initialize(AppConfig config) async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
