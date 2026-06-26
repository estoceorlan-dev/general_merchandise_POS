# JCE POS

Offline-first Flutter foundation for a scalable, multi-branch point of sale and
inventory system.

## Supported production platforms

- Windows: primary desktop POS and administration client
- Android: mobile POS and operational client
- Web: administration and operational fallback; hardware-specific POS flows
  remain Windows/Android responsibilities

The generated Linux, macOS, and iOS projects are retained for future evaluation
but are not current production targets.

The canonical application and bundle identifier is `com.jce.pos`.

## Architecture foundation

- Feature-first clean architecture under `lib/features`
- Riverpod for dependency injection and state access
- GoRouter for centralized navigation
- Drift/SQLite dependencies for the Phase 1 local database
- Typed environment configuration through Dart defines
- Shared typed `Result<Success, Failure>` and failure categories
- Centralized application logging
- Injectable clock and UUID generation
- Recoverable Firebase initialization
- Firebase Authentication with offline-cached application access profiles
- Database-driven organization, branch, role, and permission context
- PostgreSQL Phase 2 schema and deployable Firebase callable functions

## Environment configuration

JCE POS supports `development`, `staging`, and `production`. Configuration is
compiled into each build with `--dart-define`; service endpoints are never
stored as production constants in source.

Development example:

```sh
flutter run \
  --dart-define=JCE_ENV=development \
  --dart-define=JCE_ENABLE_DEMO_AUTH=true \
  --dart-define=JCE_DEMO_BRANCH_ID=demo-main
```

Production example:

```sh
flutter build windows \
  --dart-define=JCE_ENV=production \
  --dart-define=JCE_API_BASE_URL=https://your-production-service.example
```

See [Environment configuration](docs/environment_configuration.md) for the
complete strategy and variables.

## Firebase

FlutterFire options are committed for the current Firebase project. The
canonical `com.jce.pos` Android and Apple apps are registered in `jce-pos`.
Regenerate configuration whenever Firebase apps or projects change:

```sh
flutterfire configure
```

Application startup is recoverable: initialization failures show a controlled
screen with retry instead of terminating before Flutter renders.

Phase 2 authentication uses the `getMyAccessProfile` and `registerDevice`
callables under `backend/functions`. Apply
`backend/sql/phase_2_access_control.sql`, configure the database secret, and
deploy the functions before enabling production sign-in. See
[Phase 2 access backend](docs/phase_2_access_backend.md).

## Code generation

```sh
dart run build_runner build --delete-conflicting-outputs --low-resources-mode
```

For continuous generation during development:

```sh
dart run build_runner watch --delete-conflicting-outputs --low-resources-mode
```

The checked-in Drift schema snapshot under `drift_schemas/` is the migration
baseline. Before changing a released schema, increment `schemaVersion` and run:

```sh
dart run drift_dev make-migrations
```

Web builds use the checked-in `web/sqlite3.wasm` runtime and generated Drift
worker. Regenerate the worker after upgrading Drift:

```sh
dart compile js web/drift_worker.dart -O4 -o web/drift_worker.js
```

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
cd backend/functions && npm run build
```

These checks also run in GitHub Actions.
