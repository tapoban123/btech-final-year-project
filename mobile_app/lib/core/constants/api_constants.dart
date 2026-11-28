/// Central API routing and backend constants.
class ApiConstants {
  ApiConstants._();

  /// Deployed production backend base URL on Vercel.
  static const String baseUrl = 'https://btech-final-year-project-rho.vercel.app';

  /// API versioning prefix.
  static const String apiV1 = '/api/v1';

  /// Document endpoints.
  static const String documents = '$apiV1/documents';
  static const String uploadDocuments = '$apiV1/documents/upload';
  static const String queryDocuments = '$apiV1/documents/query';
  static const String searchDocuments = '$apiV1/documents/search';

  /// System health endpoint.
  static const String health = '$apiV1/health';

  /// Helper to get specific document endpoint.
  static String document(String documentId) => '$documents/$documentId';
}
