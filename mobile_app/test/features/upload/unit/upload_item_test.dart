import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/blocs/upload_state.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';

void main() {
  group('UploadItem Unit Tests', () {
    test('supports value equality via Equatable', () {
      const item1 = UploadItem(
        id: '1',
        title: 'Report.pdf',
        type: DocumentType.pdf,
        stageDescription: 'OCR',
        status: UploadProcessingStatus.processing,
      );
      const item2 = UploadItem(
        id: '1',
        title: 'Report.pdf',
        type: DocumentType.pdf,
        stageDescription: 'OCR',
        status: UploadProcessingStatus.processing,
      );

      expect(item1, equals(item2));
      expect(item1.props, [
        '1',
        'Report.pdf',
        DocumentType.pdf,
        'OCR',
        UploadProcessingStatus.processing,
        null,
      ]);
    });

    test('copyWith properly updates fields and retains unchanged ones', () {
      const original = UploadItem(
        id: '1',
        title: 'Contract.pdf',
        type: DocumentType.pdf,
        stageDescription: 'Pending',
        status: UploadProcessingStatus.processing,
      );

      final updated = original.copyWith(
        stageDescription: 'Completed indexing',
        status: UploadProcessingStatus.completed,
      );

      expect(updated.id, '1');
      expect(updated.stageDescription, 'Completed indexing');
      expect(updated.status, UploadProcessingStatus.completed);
    });

    test('UploadState formattedDuration formats seconds to MM:SS', () {
      const state1 = UploadState(recordingDurationSeconds: 165); // 02:45
      expect(state1.formattedDuration, '02:45');

      const state2 = UploadState(recordingDurationSeconds: 5); // 00:05
      expect(state2.formattedDuration, '00:05');

      const state3 = UploadState(recordingDurationSeconds: 610); // 10:10
      expect(state3.formattedDuration, '10:10');
    });

    test('UploadState activeUploadsCount calculates processing count', () {
      const list = [
        UploadItem(
          id: '1',
          title: 'A.pdf',
          type: DocumentType.pdf,
          stageDescription: 'OCR',
          status: UploadProcessingStatus.processing,
        ),
        UploadItem(
          id: '2',
          title: 'B.png',
          type: DocumentType.image,
          stageDescription: 'Done',
          status: UploadProcessingStatus.completed,
        ),
      ];

      final state = const UploadState(recentUploads: list);
      expect(state.activeUploadsCount, 1);
    });
  });
}
