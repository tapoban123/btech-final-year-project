import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/chat/api/chat_api_client.dart';
import 'package:mobile_app/features/chat/models/chat_query_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ChatApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = ChatApiClient(dio: mockDio);
  });

  group('ChatApiClient sendQuery Tests', () {
    test('returns MultiDocumentQueryResponseModel on HTTP 200', () async {
      when(() => mockDio.post(
            ApiConstants.queryDocuments,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.queryDocuments),
          statusCode: 200,
          data: {
            'answer': 'Q3 marketing spent \$420k.',
            'sources': [
              {
                'document_id': 'doc_q3',
                'document_name': 'Report.pdf',
                'page': 14,
                'snippet': 'Total \$420k spent',
              },
            ],
            'documents': [],
          },
        ),
      );

      final result = await apiClient.sendQuery(
        const DocumentQueryRequestModel(query: 'What was marketing expense?'),
      );

      expect(result.answer, 'Q3 marketing spent \$420k.');
      expect(result.sources.length, 1);
      expect(result.sources.first.documentName, 'Report.pdf');
      expect(result.sources.first.page, 14);
      verify(() => mockDio.post(
            ApiConstants.queryDocuments,
            data: any(named: 'data'),
          )).called(1);
    });

    test('falls back to default response on DioException', () async {
      when(() => mockDio.post(
            ApiConstants.queryDocuments,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.queryDocuments),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      final result = await apiClient.sendQuery(
        const DocumentQueryRequestModel(query: 'Failing prompt'),
      );

      expect(result.answer, isNotEmpty);
      expect(result.sources, isNotEmpty);
    });
  });

  group('ChatApiClient Chat History & Context Tests', () {
    test('getInitialChatHistory returns default conversation items', () async {
      final history = await apiClient.getInitialChatHistory();

      expect(history.length, 2);
      expect(history[0].sender, 'user');
      expect(history[1].sender, 'assistant');
      expect(history[1].points, isNotEmpty);
      expect(history[1].citations, isNotEmpty);
    });

    test('getActiveContexts returns default RAG context items', () async {
      final contexts = await apiClient.getActiveContexts();

      expect(contexts.length, 3);
      expect(contexts[0].id, 'ctx_1');
      expect(contexts[1].type, 'audio');
      expect(contexts[2].type, 'image');
    });
  });
}
