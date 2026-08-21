class AppConfig {
  const AppConfig._();

  /// Keeps the original remote implementation available while making the
  /// shipped application fully self-contained.
  static const bool useOfflineMode = true;

  static const Duration demoDelay = Duration(milliseconds: 400);
  static const String legacyImageBaseUrl = 'http://13.235.67.24';
}
