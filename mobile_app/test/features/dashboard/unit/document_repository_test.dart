import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/api/document_api_client.dart';
import 'package:mobile_app/features/dashboard/models/dashboard_metrics_model.dart';
import 'package:mobile_app/features/dashboard/models/document_response_model.dart';
import 'package:mobile_app/features/dashboard/repository/document_repository.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockDocumentApiClient extends Mock implements DocumentApiClient {}

void main() {
  late MockDocumentApiClient mockApiClient;
  late DocumentRepository repository;

  setUp(() {
    mockApiClient = MockDocumentApiClient();
    repository = DocumentRepository(apiClient: mockApiClient);
  });

  group('DocumentRepository with Mock Responses', () {
    test('getDocuments maps DocumentsResponseModel to List<DocumentItem>',
        () async {
      when(() => mockApiClient.getDocuments()).thenAnswer(
        (_) async => const DocumentsResponseModel(
          documents: [
            DocumentMetadataModel(
              documentId: 'mock_1',
              filename: 'Test_Contract.pdf',
              sizeBytes: 3670016,
              status: 'Parsed',
              createdAt: '2026-10-25T00:00:00.000Z',
            ),
            DocumentMetadataModel(
              documentId: 'mock_2',
              filename: 'Diagram.png',
              sizeBytes: 1258291,
              status: 'OCR Ready',
              createdAt: '2026-10-24T00:00:00.000Z',
              mimeType: 'image/png',
            ),
          ],
        ),
      );

      final result = await repository.getDocuments();

      expect(result.length, 2);
      expect(result.first.id, 'mock_1');
      expect(result.first.type, DocumentType.pdf);
      expect(result[1].type, DocumentType.image);
      verify(() => mockApiClient.getDocuments()).called(1);
    });

    test('getDocuments handles empty response list correctly', () async {
      when(() => mockApiClient.getDocuments()).thenAnswer(
        (_) async => const DocumentsResponseModel(documents: []),
      );

      final result = await repository.getDocuments();

      expect(result, isEmpty);
      verify(() => mockApiClient.getDocuments()).called(1);
    });

    test(
        'getDocuments handles unknown file type gracefully by defaulting to pdf',
        () async {
      when(() => mockApiClient.getDocuments()).thenAnswer(
        (_) async => const DocumentsResponseModel(
          documents: [
            DocumentMetadataModel(
              documentId: 'unknown_type',
              filename: 'Arbitrary_File.xyz',
              sizeBytes: 512000,
              status: 'Unknown',
            ),
          ],
        ),
      );

      final result = await repository.getDocuments();
      expect(result.first.type, DocumentType.pdf);
    });

    test('getMetrics maps DashboardMetricsModel to DashboardMetrics', () async {
      when(() => mockApiClient.getDashboardMetrics()).thenAnswer(
        (_) async => const DashboardMetricsModel(
          synthesizedDocsCount: 42,
          audioNotesHours: 8.5,
          confidencePercentage: 99.8,
        ),
      );

      final metrics = await repository.getMetrics();

      expect(metrics.synthesizedDocsCount, 42);
      expect(metrics.audioNotesHours, 8.5);
      expect(metrics.confidencePercentage, 99.8);
      verify(() => mockApiClient.getDashboardMetrics()).called(1);
    });

    test('rethrows exception when API client fails', () async {
      when(() => mockApiClient.getDocuments())
          .thenThrow(Exception('Network timeout error 504'));

      expect(() => repository.getDocuments(), throwsA(isA<Exception>()));
    });
  });
}
