import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/dashboard/api/document_api_client.dart';
import 'package:mobile_app/features/dashboard/models/document_search_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DocumentApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = DocumentApiClient(dio: mockDio);
  });

  group('DocumentApiClient getDocuments Tests', () {
    test('returns DocumentsResponseModel when HTTP 200 with map payload',
        () async {
      when(() => mockDio.get(ApiConstants.documents)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.documents),
          statusCode: 200,
          data: {
            'documents': [
              {
                'document_id': 'doc_api_1',
                'filename': 'Q3_Financials.pdf',
                'size_bytes': 1024000,
                'status': 'completed',
                'created_at': '2026-11-28T10:00:00.000Z',
              },
            ],
          },
        ),
      );

      final result = await apiClient.getDocuments();

      expect(result.documents.length, 1);
      expect(result.documents.first.documentId, 'doc_api_1');
      expect(result.documents.first.filename, 'Q3_Financials.pdf');
      verify(() => mockDio.get(ApiConstants.documents)).called(1);
    });

    test('returns DocumentsResponseModel when HTTP 200 with list payload',
        () async {
      when(() => mockDio.get(ApiConstants.documents)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.documents),
          statusCode: 200,
          data: [
            {
              'document_id': 'doc_list_1',
              'filename': 'Direct_List.pdf',
              'size_bytes': 500,
            },
          ],
        ),
      );

      final result = await apiClient.getDocuments();

      expect(result.documents.length, 1);
      expect(result.documents.first.documentId, 'doc_list_1');
    });

    test('falls back to default documents on DioException', () async {
      when(() => mockDio.get(ApiConstants.documents)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.documents),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await apiClient.getDocuments();

      expect(result.documents, isNotEmpty);
      expect(result.documents.first.filename,
          'Q3_Financial_Analysis_Report.pdf');
    });
  });

  group('DocumentApiClient getDashboardMetrics Tests', () {
    test('returns DashboardMetricsModel with prototype counts', () async {
      final metrics = await apiClient.getDashboardMetrics();

      expect(metrics.synthesizedDocsCount, 24);
      expect(metrics.audioNotesHours, 4.8);
      expect(metrics.confidencePercentage, 99.4);
    });
  });

  group('DocumentApiClient searchDocuments Tests', () {
    test('returns DocumentSearchResponseModel on HTTP 200', () async {
      when(() => mockDio.post(
            ApiConstants.searchDocuments,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.searchDocuments),
          statusCode: 200,
          data: {
            'query': 'audit risk',
            'documents': [
              {
                'document_id': 'search_doc_1',
                'filename': 'Audit_v2.pdf',
                'score': 0.88,
              },
            ],
          },
        ),
      );

      final result = await apiClient.searchDocuments(
        const DocumentSearchRequestModel(query: 'audit risk'),
      );

      expect(result.query, 'audit risk');
      expect(result.documents.length, 1);
      expect(result.documents.first.documentId, 'search_doc_1');
      expect(result.documents.first.score, 0.88);
    });

    test('falls back to empty documents on DioException', () async {
      when(() => mockDio.post(
            ApiConstants.searchDocuments,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.searchDocuments),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await apiClient.searchDocuments(
        const DocumentSearchRequestModel(query: 'failing query'),
      );

      expect(result.query, 'failing query');
      expect(result.documents, isEmpty);
    });
  });
}
