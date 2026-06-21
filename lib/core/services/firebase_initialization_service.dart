import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseInitializationServiceProvider =
    Provider<FirebaseInitializationService>((ref) {
      return const FirebaseInitializationService();
    });

class FirebaseInitializationService {
  const FirebaseInitializationService();

  Future<FirebaseApp> initialize({FirebaseOptions? options, String? name}) {
    if (Firebase.apps.isNotEmpty) {
      return Future.value(name == null ? Firebase.app() : Firebase.app(name));
    }

    if (options != null) {
      return Firebase.initializeApp(name: name, options: options);
    }

    return Firebase.initializeApp(name: name);
  }
}
