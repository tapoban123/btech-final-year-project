import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/api/upload_api_client.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/repository/upload_repository.dart';

class MockUploadApiClient extends Mock implements UploadApiClient {}

void main() {
  late MockUploadApiClient mockApiClient;
  late UploadRepository repository;

  setUp(() {
    mockApiClient = MockUploadApiClient();
    repository = UploadRepository(apiClient: mockApiClient);
  });

  group('UploadRepository with Mock Responses', () {
    test('getRecentUploads maps raw API data to List<UploadItem>', () async {
      when(() => mockApiClient.getRecentUploadsRaw()).thenAnswer(
        (_) async => [
          {
            'id': 'u1',
            'title': 'Contract.pdf',
            'type': 'pdf',
            'stageDescription': 'Analyzing semantic vectors',
            'status': 'processing',
          },
          {
            'id': 'u2',
            'title': 'Whiteboard.png',
            'type': 'image',
            'stageDescription': 'OCR complete',
            'status': 'completed',
          },
        ],
      );

      final uploads = await repository.getRecentUploads();

      expect(uploads.length, 2);
      expect(uploads.first.title, 'Contract.pdf');
      expect(uploads.first.type, DocumentType.pdf);
      expect(uploads.first.status, UploadProcessingStatus.processing);
      expect(uploads[1].type, DocumentType.image);
      expect(uploads[1].status, UploadProcessingStatus.completed);
    });

    test('uploadFile sends file details and returns created UploadItem',
        () async {
      when(() => mockApiClient.uploadFileRaw('New_File.pdf', 'pdf')).thenAnswer(
        (_) async => {
          'id': 'up_new',
          'title': 'New_File.pdf',
          'type': 'pdf',
          'stageDescription': 'Queued',
          'status': 'processing',
        },
      );

      final item = await repository.uploadFile('New_File.pdf', DocumentType.pdf);

      expect(item.id, 'up_new');
      expect(item.title, 'New_File.pdf');
      expect(item.type, DocumentType.pdf);
    });

    test('saveVoiceMemo sends duration and returns created memo UploadItem',
        () async {
      when(() => mockApiClient.saveVoiceMemoRaw(120)).thenAnswer(
        (_) async => {
          'id': 'memo_123',
          'title': 'Voice_Memo_123.m4a',
          'type': 'audio',
          'stageDescription': 'Transcribing audio vectors',
          'status': 'processing',
        },
      );

      final memo = await repository.saveVoiceMemo(120);

      expect(memo.id, 'memo_123');
      expect(memo.type, DocumentType.audio);
    });

    test('propagates exception when API fails', () async {
      when(() => mockApiClient.getRecentUploadsRaw())
          .thenThrow(Exception('Server Error 500'));

      expect(() => repository.getRecentUploads(), throwsA(isA<Exception>()));
    });
  });
}
