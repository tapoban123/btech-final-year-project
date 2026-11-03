import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/api/document_api_client.dart';
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
    test('getDocuments maps raw API response to List<DocumentItem>', () async {
      when(() => mockApiClient.getDocumentsRaw()).thenAnswer(
        (_) async => [
          {
            'id': 'mock_1',
            'title': 'Test_Contract.pdf',
            'type': 'pdf',
            'fileSize': '3.5 MB',
            'date': 'Oct 25',
            'statusTag': 'Parsed',
            'isStatusHighlighted': true,
            'isSelected': true,
          },
          {
            'id': 'mock_2',
            'title': 'Diagram.png',
            'type': 'image',
            'fileSize': '1.2 MB',
            'date': 'Oct 24',
            'statusTag': 'OCR Ready',
          },
        ],
      );

      final result = await repository.getDocuments();

      expect(result.length, 2);
      expect(result.first.id, 'mock_1');
      expect(result.first.type, DocumentType.pdf);
      expect(result.first.isSelected, isTrue);
      expect(result[1].type, DocumentType.image);
      verify(() => mockApiClient.getDocumentsRaw()).called(1);
    });

    test('getDocuments handles empty response list correctly', () async {
      when(() => mockApiClient.getDocumentsRaw()).thenAnswer((_) async => []);

      final result = await repository.getDocuments();

      expect(result, isEmpty);
      verify(() => mockApiClient.getDocumentsRaw()).called(1);
    });

    test('getDocuments handles unknown file type gracefully by defaulting to pdf',
        () async {
      when(() => mockApiClient.getDocumentsRaw()).thenAnswer(
        (_) async => [
          {
            'id': 'unknown_type',
            'title': 'Arbitrary_File.xyz',
            'type': 'unsupported_extension',
            'fileSize': '500 KB',
            'date': 'Oct 20',
            'statusTag': 'Unknown',
          },
        ],
      );

      final result = await repository.getDocuments();
      expect(result.first.type, DocumentType.pdf);
    });

    test('getMetrics maps raw metric data to DashboardMetrics', () async {
      when(() => mockApiClient.getDashboardMetricsRaw()).thenAnswer(
        (_) async => {
          'synthesizedDocsCount': 42,
          'audioNotesHours': 8.5,
          'confidencePercentage': 99.8,
        },
      );

      final metrics = await repository.getMetrics();

      expect(metrics.synthesizedDocsCount, 42);
      expect(metrics.audioNotesHours, 8.5);
      expect(metrics.confidencePercentage, 99.8);
      verify(() => mockApiClient.getDashboardMetricsRaw()).called(1);
    });

    test('rethrows exception when API client fails', () async {
      when(() => mockApiClient.getDocumentsRaw())
          .thenThrow(Exception('Network timeout error 504'));

      expect(() => repository.getDocuments(), throwsA(isA<Exception>()));
    });
  });
}
