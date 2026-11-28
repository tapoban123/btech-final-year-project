import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/upload/models/upload_response_model.dart';

void main() {
  group('DocumentUploadResponseModel Unit Tests', () {
    test('deserializes from backend upload response JSON', () {
      final json = {
        'id': 'up_123',
        'document_id': 'doc_upload_123',
        'filename': 'Spec_Sheet.pdf',
        'content_type': 'application/pdf',
        'size_bytes': 456000,
        'status': 'completed',
        'message': 'Document uploaded and indexed successfully',
        'cloudinary_public_id': 'cld_spec_123',
      };

      final model = DocumentUploadResponseModel.fromJson(json);

      expect(model.id, 'up_123');
      expect(model.documentId, 'doc_upload_123');
      expect(model.resolvedId, 'doc_upload_123');
      expect(model.filename, 'Spec_Sheet.pdf');
      expect(model.contentType, 'application/pdf');
      expect(model.sizeBytes, 456000);
      expect(model.status, 'completed');
      expect(model.message, 'Document uploaded and indexed successfully');
      expect(model.cloudinaryPublicId, 'cld_spec_123');
    });

    test('resolvedId falls back to id if document_id is null', () {
      final json = {
        'id': 'fallback_id_789',
        'filename': 'Receipt.jpg',
      };

      final model = DocumentUploadResponseModel.fromJson(json);

      expect(model.documentId, isNull);
      expect(model.id, 'fallback_id_789');
      expect(model.resolvedId, 'fallback_id_789');
    });

    test('default values are populated when fields are missing', () {
      final model = DocumentUploadResponseModel.fromJson({});

      expect(model.filename, '');
      expect(model.contentType, '');
      expect(model.sizeBytes, 0);
      expect(model.status, 'completed');
      expect(model.message, '');
      expect(model.resolvedId, '');
    });
  });

  group('DocumentBatchUploadResponseModel Unit Tests', () {
    test('deserializes batch results correctly', () {
      final json = {
        'total_files': 2,
        'successful': 2,
        'failed': 0,
        'results': [
          {
            'document_id': 'd1',
            'filename': 'f1.pdf',
            'status': 'completed',
          },
          {
            'document_id': 'd2',
            'filename': 'f2.png',
            'status': 'completed',
          },
        ],
      };

      final batch = DocumentBatchUploadResponseModel.fromJson(json);

      expect(batch.totalFiles, 2);
      expect(batch.successful, 2);
      expect(batch.failed, 0);
      expect(batch.results.length, 2);
      expect(batch.results.first.documentId, 'd1');
      expect(batch.results[1].filename, 'f2.png');
    });

    test('toJson produces valid batch upload map', () {
      const batch = DocumentBatchUploadResponseModel(
        totalFiles: 1,
        successful: 1,
        failed: 0,
        results: [
          DocumentUploadResponseModel(
            documentId: 'd_solo',
            filename: 'solo.pdf',
          ),
        ],
      );

      final json = batch.toJson();

      expect(json['total_files'], 1);
      expect(json['successful'], 1);
      expect(json['failed'], 0);
      expect((json['results'] as List).length, 1);
    });
  });

  group('VoiceMemoResponseModel Unit Tests', () {
    test('serializes and deserializes accurately', () {
      const memo = VoiceMemoResponseModel(
        id: 'memo_42',
        title: 'Interview_Memo.m4a',
        type: 'audio',
        stageDescription: 'Transcribing voice memo',
        status: 'processing',
      );

      final json = memo.toJson();
      final fromJson = VoiceMemoResponseModel.fromJson(json);

      expect(fromJson.id, 'memo_42');
      expect(fromJson.title, 'Interview_Memo.m4a');
      expect(fromJson.type, 'audio');
      expect(fromJson.stageDescription, 'Transcribing voice memo');
      expect(fromJson.status, 'processing');
    });
  });
}
