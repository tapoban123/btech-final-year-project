import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/models/dashboard_metrics_model.dart';
import 'package:mobile_app/features/dashboard/models/document_response_model.dart';
import 'package:mobile_app/features/dashboard/models/document_search_model.dart';

void main() {
  group('DocumentMetadataModel Unit Tests', () {
    test('deserializes from full backend JSON payload', () {
      final json = {
        'document_id': 'doc_123',
        'filename': 'Annual_Report.pdf',
        'size_bytes': 2048000,
        'status': 'completed',
        'created_at': '2026-11-28T12:00:00.000Z',
        'cloudinary_url': 'https://res.cloudinary.com/demo/doc_123.pdf',
        'mime_type': 'application/pdf',
      };

      final model = DocumentMetadataModel.fromJson(json);

      expect(model.documentId, 'doc_123');
      expect(model.resolvedId, 'doc_123');
      expect(model.filename, 'Annual_Report.pdf');
      expect(model.sizeBytes, 2048000);
      expect(model.status, 'completed');
      expect(model.createdAt, '2026-11-28T12:00:00.000Z');
      expect(model.cloudinaryUrl,
          'https://res.cloudinary.com/demo/doc_123.pdf');
      expect(model.mimeType, 'application/pdf');
    });

    test('resolvedId falls back to id when document_id is omitted', () {
      final json = {
        'id': 'legacy_id_456',
        'filename': 'Notes.txt',
      };

      final model = DocumentMetadataModel.fromJson(json);

      expect(model.documentId, '');
      expect(model.id, 'legacy_id_456');
      expect(model.resolvedId, 'legacy_id_456');
    });

    test('toJson produces correct snake_case keys', () {
      const model = DocumentMetadataModel(
        documentId: 'doc_99',
        filename: 'Summary.pdf',
        sizeBytes: 1024,
        status: 'completed',
      );

      final json = model.toJson();

      expect(json['document_id'], 'doc_99');
      expect(json['filename'], 'Summary.pdf');
      expect(json['size_bytes'], 1024);
      expect(json['status'], 'completed');
    });

    test('copyWith preserves and updates properties', () {
      const model = DocumentMetadataModel(
        documentId: 'doc_1',
        filename: 'Original.pdf',
      );

      final updated = model.copyWith(filename: 'Updated.pdf', sizeBytes: 500);

      expect(updated.documentId, 'doc_1');
      expect(updated.filename, 'Updated.pdf');
      expect(updated.sizeBytes, 500);
    });
  });

  group('DocumentsResponseModel Unit Tests', () {
    test('deserializes document list correctly', () {
      final json = {
        'documents': [
          {
            'document_id': 'd1',
            'filename': 'file1.pdf',
            'size_bytes': 100,
          },
          {
            'document_id': 'd2',
            'filename': 'file2.png',
            'size_bytes': 200,
          },
        ],
      };

      final response = DocumentsResponseModel.fromJson(json);

      expect(response.documents.length, 2);
      expect(response.documents.first.documentId, 'd1');
      expect(response.documents[1].filename, 'file2.png');
    });

    test('handles empty document list', () {
      final response = DocumentsResponseModel.fromJson({'documents': []});
      expect(response.documents, isEmpty);
    });
  });

  group('DocumentSearch Models Unit Tests', () {
    test('DocumentSearchRequestModel serializes correctly', () {
      const request = DocumentSearchRequestModel(query: 'revenue Q3');
      expect(request.toJson(), {'query': 'revenue Q3'});
    });

    test('DocumentSearchResponseModel deserializes results with scores', () {
      final json = {
        'query': 'revenue Q3',
        'documents': [
          {
            'document_id': 'doc_res_1',
            'filename': 'Report.pdf',
            'cloudinary_url': 'https://cloudinary.com/demo.pdf',
            'score': 0.94,
          },
        ],
      };

      final response = DocumentSearchResponseModel.fromJson(json);

      expect(response.query, 'revenue Q3');
      expect(response.documents.length, 1);
      expect(response.documents.first.documentId, 'doc_res_1');
      expect(response.documents.first.score, 0.94);
      expect(response.documents.first.cloudinaryUrl,
          'https://cloudinary.com/demo.pdf');
    });
  });

  group('DashboardMetricsModel Unit Tests', () {
    test('deserializes snake_case keys correctly', () {
      final json = {
        'synthesized_docs_count': 50,
        'audio_notes_hours': 12.5,
        'confidence_percentage': 98.7,
      };

      final model = DashboardMetricsModel.fromJson(json);

      expect(model.synthesizedDocsCount, 50);
      expect(model.audioNotesHours, 12.5);
      expect(model.confidencePercentage, 98.7);
    });

    test('deserializes camelCase keys correctly', () {
      final json = {
        'synthesizedDocsCount': 35,
        'audioNotesHours': 6.2,
        'confidencePercentage': 97.9,
      };

      final model = DashboardMetricsModel.fromJson(json);

      expect(model.synthesizedDocsCount, 35);
      expect(model.audioNotesHours, 6.2);
      expect(model.confidencePercentage, 97.9);
    });

    test('defaults values when keys are missing', () {
      final model = DashboardMetricsModel.fromJson({});

      expect(model.synthesizedDocsCount, 24);
      expect(model.audioNotesHours, 4.8);
      expect(model.confidencePercentage, 99.4);
    });
  });
}
