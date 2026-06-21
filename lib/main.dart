import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/firebase_initialization_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await const FirebaseInitializationService().initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: JcePosApp()));
}
