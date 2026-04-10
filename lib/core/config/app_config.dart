class AppConfig {
  static const bool useFirebase = true;
  static bool firebaseInitialized = false;
  static bool get isFirebaseEnabled => useFirebase && firebaseInitialized;
  static const bool enableJobsApi = false;

  static const String jobsBaseUrl = 'https://example.com';
  static const String jobsPath = '/api/jobs';
}
