import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/core/network/dio_client.dart';

void main() {
  group('DioClient & ApiConstants Tests', () {
    test('ApiConstants contains correct baseUrl and endpoints', () {
      expect(
        ApiConstants.baseUrl,
        'https://btech-final-year-project-rho.vercel.app',
      );
      expect(ApiConstants.documents, '/api/v1/documents');
      expect(ApiConstants.uploadDocuments, '/api/v1/documents/upload');
      expect(ApiConstants.queryDocuments, '/api/v1/documents/query');
      expect(ApiConstants.searchDocuments, '/api/v1/documents/search');
      expect(ApiConstants.health, '/api/v1/health');
      expect(ApiConstants.document('doc_123'), '/api/v1/documents/doc_123');
    });

    test('DioClient factory returns configured singleton instance with correct baseUrl', () {
      final client1 = DioClient();
      final client2 = DioClient();

      expect(identical(client1, client2), isTrue);
      expect(client1.dio.options.baseUrl, ApiConstants.baseUrl);
      expect(client1.dio.options.headers['Content-Type'], 'application/json');
      expect(client1.dio.options.headers['Accept'], 'application/json');
      expect(client1.dio.options.connectTimeout, const Duration(seconds: 30));
    });

    test('DioClient factory with customDio wraps custom instance', () {
      final custom = Dio(BaseOptions(baseUrl: 'https://custom-test.com'));
      final client = DioClient(customDio: custom);

      expect(identical(client.dio, custom), isTrue);
      expect(client.dio.options.baseUrl, 'https://custom-test.com');
    });
  });
}
