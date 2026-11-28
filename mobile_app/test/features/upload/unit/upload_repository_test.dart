import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/api/upload_api_client.dart';
import 'package:mobile_app/features/upload/models/upload_response_model.dart';
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
    test('getRecentUploads maps DocumentUploadResponseModel to List<UploadItem>',
        () async {
      when(() => mockApiClient.getRecentUploads()).thenAnswer(
        (_) async => const [
          DocumentUploadResponseModel(
            documentId: 'u1',
            filename: 'Contract.pdf',
            contentType: 'application/pdf',
            message: 'Analyzing semantic vectors',
            status: 'processing',
          ),
          DocumentUploadResponseModel(
            documentId: 'u2',
            filename: 'Whiteboard.png',
            contentType: 'image/png',
            message: 'OCR complete',
            status: 'completed',
          ),
        ],
      );

      final uploads = await repository.getRecentUploads();

      expect(uploads.length, 2);
      expect(uploads.first.title, 'Contract.pdf');
      expect(uploads.first.type, DocumentType.pdf);
      expect(uploads.first.status, UploadProcessingStatus.processing);
      expect(uploads[1].type, DocumentType.image);
      expect(uploads[1].status, UploadProcessingStatus.completed);
      verify(() => mockApiClient.getRecentUploads()).called(1);
    });

    test('uploadFile sends file details and returns created UploadItem',
        () async {
      when(() => mockApiClient.uploadFile(
            'New_File.pdf',
            'pdf',
            filePath: any(named: 'filePath'),
          )).thenAnswer(
        (_) async => const DocumentUploadResponseModel(
          documentId: 'up_new',
          filename: 'New_File.pdf',
          contentType: 'application/pdf',
          message: 'Queued',
          status: 'processing',
        ),
      );

      final item =
          await repository.uploadFile('New_File.pdf', DocumentType.pdf);

      expect(item.id, 'up_new');
      expect(item.title, 'New_File.pdf');
      expect(item.type, DocumentType.pdf);
    });

    test('saveVoiceMemo sends duration and returns created memo UploadItem',
        () async {
      when(() => mockApiClient.saveVoiceMemo(120)).thenAnswer(
        (_) async => const VoiceMemoResponseModel(
          id: 'memo_123',
          title: 'Voice_Memo_123.m4a',
          type: 'audio',
          stageDescription: 'Transcribing audio vectors',
          status: 'processing',
        ),
      );

      final memo = await repository.saveVoiceMemo(120);

      expect(memo.id, 'memo_123');
      expect(memo.type, DocumentType.audio);
      verify(() => mockApiClient.saveVoiceMemo(120)).called(1);
    });

    test('propagates exception when API fails', () async {
      when(() => mockApiClient.getRecentUploads())
          .thenThrow(Exception('Server Error 500'));

      expect(() => repository.getRecentUploads(), throwsA(isA<Exception>()));
    });
  });
}
