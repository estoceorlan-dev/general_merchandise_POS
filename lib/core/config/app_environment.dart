enum AppEnvironment {
  development,
  staging,
  production;

  bool get isProduction => this == AppEnvironment.production;

  static AppEnvironment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' || 'dev' => AppEnvironment.development,
      'staging' || 'stage' => AppEnvironment.staging,
      'production' || 'prod' => AppEnvironment.production,
      _ => throw FormatException('Unsupported JCE_ENV value: $value'),
    };
  }
}
