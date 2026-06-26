# Environment Configuration

## Environments

JCE POS has three explicit environments:

| Environment | Purpose | Demo authentication | Diagnostics |
|---|---|---:|---:|
| Development | Local development and automated tests | Allowed explicitly | On by default |
| Staging | Release candidate and integration verification | Off by default | On by default |
| Production | Branch deployment | Disabled | Off by default |

Each environment should use a separate Firebase project, SQL Connect database,
service account boundary, and deployment pipeline. Production data must never
be copied into development.

## Dart define values

| Key | Required | Description |
|---|---:|---|
| `JCE_ENV` | Yes for release builds | `development`, `staging`, or `production` |
| `JCE_API_BASE_URL` | When remote sync is enabled | Absolute service URL |
| `JCE_ENABLE_DEMO_AUTH` | No | Enables the development-only demo repository |
| `JCE_DEMO_BRANCH_ID` | When demo auth is enabled | Non-production demo branch identifier |
| `JCE_ENABLE_DIAGNOSTICS` | No | Enables additional non-sensitive diagnostics |
| `JCE_FIREBASE_FUNCTIONS_REGION` | No | Firebase Functions region override. Defaults to `asia-southeast1` |
| `JCE_ACCESS_PROFILE_FUNCTION` | No | Callable name used to load the current access profile |
| `JCE_DEVICE_REGISTRATION_FUNCTION` | No | Callable name used to register the local device |
| `JCE_UPDATE_BRANCH_NAME_FUNCTION` | No | Callable name used to update a branch label |

Values are parsed by `AppConfig` and can be replaced in tests through
`appConfigProvider.overrideWithValue(...)`.

For the `jce-pos` Firebase project, the Flutter app automatically targets
`asia-southeast1`, matching the deployed callable Functions. Set
`JCE_FIREBASE_FUNCTIONS_REGION` only when running against another Firebase
project or region.

## Firebase Functions environment values

These values are non-secret deployment identifiers and are loaded from
`backend/functions/.env.jce-pos` during deploy:

| Key | Description |
|---|---|
| `JCE_FUNCTIONS_REGION` | Firebase Functions deployment region |
| `JCE_DB_INSTANCE_CONNECTION_NAME` | Cloud SQL instance connection name |
| `JCE_DB_NAME` | PostgreSQL database name |
| `JCE_DB_USER` | PostgreSQL IAM database username |
| `JCE_FUNCTIONS_SERVICE_ACCOUNT` | Google service account used by deployed callables |

## Rules

- Never commit passwords, private keys, access tokens, or service-account JSON.
- Never hardcode production endpoints or branch identifiers.
- Keep Firebase client configuration environment-specific.
- Treat Firebase client API keys as identifiers, not server credentials.
- Use CI secret storage for signing material and deployment credentials.
- Demo authentication must remain disabled for staging and production builds.

## Build examples

```sh
flutter build apk \
  --dart-define=JCE_ENV=staging \
  --dart-define=JCE_API_BASE_URL=https://your-staging-service.example
```

```sh
flutter build windows \
  --dart-define=JCE_ENV=production \
  --dart-define=JCE_API_BASE_URL=https://your-production-service.example
```
