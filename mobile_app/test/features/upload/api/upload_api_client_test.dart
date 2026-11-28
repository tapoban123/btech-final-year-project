import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/upload/api/upload_api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late UploadApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = UploadApiClient(dio: mockDio);
  });

  group('UploadApiClient uploadFile Tests', () {
    test('returns local processing model when filePath is not provided',
        () async {
      final result = await apiClient.uploadFile('Virtual_Doc.pdf', 'pdf');

      expect(result.filename, 'Virtual_Doc.pdf');
      expect(result.contentType, 'pdf');
      expect(result.status, 'processing');
      verifyZeroInteractions(mockDio);
    });

    test('posts FormData and returns DocumentUploadResponseModel on HTTP 201',
        () async {
      when(() => mockDio.post(
            ApiConstants.uploadDocuments,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.uploadDocuments),
          statusCode: 201,
          data: {
            'total_files': 1,
            'successful': 1,
            'failed': 0,
            'results': [
              {
                'document_id': 'doc_uploaded_1',
                'filename': 'Test_Uploaded.pdf',
                'content_type': 'application/pdf',
                'size_bytes': 2048,
                'status': 'completed',
                'message': 'Indexed successfully',
              },
            ],
          },
        ),
      );

      // Create a dummy memory file or test path
      final result = await apiClient.uploadFile(
        'Test_Uploaded.pdf',
        'application/pdf',
        filePath: 'test/core/network/dio_client_test.dart', // valid existing file
      );

      expect(result.documentId, 'doc_uploaded_1');
      expect(result.filename, 'Test_Uploaded.pdf');
      expect(result.status, 'completed');
      expect(result.message, 'Indexed successfully');
      verify(() => mockDio.post(
            ApiConstants.uploadDocuments,
            data: any(named: 'data'),
          )).called(1);
    });

    test('rethrows DioException when file upload fails', () async {
      when(() => mockDio.post(
            ApiConstants.uploadDocuments,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.uploadDocuments),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => apiClient.uploadFile(
          'Failed_Upload.pdf',
          'application/pdf',
          filePath: 'test/core/network/dio_client_test.dart',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('UploadApiClient VoiceMemo and RecentUploads Tests', () {
    test('saveVoiceMemo returns VoiceMemoResponseModel', () async {
      final memo = await apiClient.saveVoiceMemo(180);

      expect(memo.id, startsWith('memo_'));
      expect(memo.type, 'audio');
      expect(memo.stageDescription, 'Transcribing audio vectors');
      expect(memo.status, 'processing');
    });

    test('getRecentUploads returns empty list', () async {
      final uploads = await apiClient.getRecentUploads();
      expect(uploads, isEmpty);
    });
  });
}
