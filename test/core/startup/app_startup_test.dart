import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jce_pos/core/config/app_config.dart';
import 'package:jce_pos/core/config/app_environment.dart';
import 'package:jce_pos/core/services/firebase_initialization_service.dart';
import 'package:jce_pos/core/startup/app_initialization_service.dart';
import 'package:jce_pos/core/startup/app_startup.dart';

void main() {
  const testConfig = AppConfig(
    environment: AppEnvironment.development,
    enableDemoAuth: true,
    enableDiagnostics: true,
    demoBranchId: 'test-branch',
  );

  testWidgets('starts the login shell when initialization succeeds', (
    tester,
  ) async {
    final initializer = _FakeInitializationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          firebaseInitializationServiceProvider.overrideWithValue(initializer),
        ],
        child: const AppStartup(),
      ),
    );
    await tester.pumpAndSettle();

    expect(initializer.calls, 1);
    expect(find.text('Sign in to your workspace'), findsOneWidget);
  });

  testWidgets('shows a controlled error and can retry initialization', (
    tester,
  ) async {
    final initializer = _FakeInitializationService(failuresRemaining: 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          firebaseInitializationServiceProvider.overrideWithValue(initializer),
        ],
        child: const AppStartup(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('JCE POS could not start'), findsOneWidget);
    expect(find.text('Retry initialization'), findsOneWidget);

    await tester.tap(find.text('Retry initialization'));
    await tester.pumpAndSettle();

    expect(initializer.calls, 2);
    expect(find.text('Sign in to your workspace'), findsOneWidget);
  });
}

class _FakeInitializationService implements AppInitializationService {
  _FakeInitializationService({this.failuresRemaining = 0});

  int failuresRemaining;
  int calls = 0;

  @override
  Future<void> initialize(AppConfig config) async {
    calls += 1;
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw StateError('Simulated initialization failure.');
    }
  }
}
