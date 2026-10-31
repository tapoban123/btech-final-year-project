import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/view/widgets/recent_uploads_card.dart';
import 'package:mobile_app/features/upload/view/widgets/upload_action_cards.dart';
import 'package:mobile_app/features/upload/view/widgets/upload_header.dart';
import 'package:mobile_app/features/upload/view/widgets/voice_recording_card.dart';

void main() {
  group('Upload Component Widget Tests', () {
    testWidgets('UploadHeader renders title and back arrow', (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: UploadHeader(
              onBackTap: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Upload Documents'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backTapped, isTrue);
    });

    testWidgets('UploadActionCards renders cards and triggers taps',
        (tester) async {
      bool uploadFilesTapped = false;
      bool recordVoiceTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UploadActionCards(
              onUploadFilesTap: () => uploadFilesTapped = true,
              onRecordVoiceTap: () => recordVoiceTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Upload Files'), findsOneWidget);
      expect(find.text('PDF, TXT, JPG, PNG'), findsOneWidget);
      expect(find.text('Drag or browse'), findsOneWidget);

      expect(find.text('Record Voice Note'), findsOneWidget);
      expect(find.text('Dictate memos directly'), findsOneWidget);

      await tester.tap(find.text('Upload Files'));
      expect(uploadFilesTapped, isTrue);

      await tester.tap(find.text('Record Voice Note'));
      expect(recordVoiceTapped, isTrue);
    });

    testWidgets('RecentUploadsCard renders selected count and progress indicator on processing',
        (tester) async {
      const items = [
        UploadItem(
          id: '1',
          title: 'Contract_2025.pdf',
          type: DocumentType.pdf,
          stageDescription: '2.5 MB',
          status: UploadProcessingStatus.processing,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentUploadsCard(uploads: items),
          ),
        ),
      );

      expect(find.text('Recent Uploads'), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Contract_2025.pdf'), findsOneWidget);
      expect(find.text('2.5 MB'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing...'), findsNothing);
    });

    testWidgets('RecentUploadsCard converts progress indicator to check mark when completed',
        (tester) async {
      const items = [
        UploadItem(
          id: '1',
          title: 'Contract_2025.pdf',
          type: DocumentType.pdf,
          stageDescription: '2.5 MB',
          status: UploadProcessingStatus.completed,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentUploadsCard(uploads: items),
          ),
        ),
      );

      expect(find.text('Recent Uploads'), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('RecentUploadsCard triggers onRemoveItem when delete icon is tapped',
        (tester) async {
      String? removedId;
      const items = [
        UploadItem(
          id: 'item_to_remove',
          title: 'Notes.docx',
          type: DocumentType.docx,
          stageDescription: '1.2 MB',
          status: UploadProcessingStatus.queued,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentUploadsCard(
              uploads: items,
              onRemoveItem: (id) => removedId = id,
            ),
          ),
        ),
      );

      expect(find.text('Notes.docx'), findsOneWidget);
      expect(find.byKey(const Key('delete_upload_item_to_remove')), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete_upload_item_to_remove')));
      await tester.pump();

      expect(removedId, 'item_to_remove');
    });

    testWidgets('RecentUploadsCard triggers onPreviewItem when item row is tapped',
        (tester) async {
      UploadItem? previewedItem;
      const items = [
        UploadItem(
          id: 'item_to_preview',
          title: 'Invoice.pdf',
          type: DocumentType.pdf,
          stageDescription: '2.0 MB',
          status: UploadProcessingStatus.queued,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentUploadsCard(
              uploads: items,
              onPreviewItem: (item) => previewedItem = item,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('upload_item_item_to_preview')));
      await tester.pump();

      expect(previewedItem?.id, 'item_to_preview');
      expect(previewedItem?.title, 'Invoice.pdf');
    });

    testWidgets(
        'VoiceRecordingCard renders idle state and triggers onRecord on tap to speak',
        (tester) async {
      bool recorded = false;
      bool done = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceRecordingCard(
              isRecording: false,
              formattedTime: '00:00',
              onRecord: () => recorded = true,
              onDone: () => done = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Voice Note'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Tap mic to speak'), findsOneWidget);
      expect(find.byKey(const Key('voice_recorder_delete_button')), findsOneWidget);
      expect(find.byKey(const Key('voice_recorder_record_button')), findsOneWidget);
      expect(find.byKey(const Key('voice_recorder_done_button')), findsOneWidget);

      final recordBtn = tester.widget<IconButton>(
        find.byKey(const Key('voice_recorder_record_button')),
      );
      expect(recordBtn.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('voice_recorder_record_button')));
      expect(recorded, isTrue);
      expect(done, isFalse);
      expect(deleted, isFalse);
    });

    testWidgets(
        'VoiceRecordingCard disables record button while recording and handles done and delete',
        (tester) async {
      bool recorded = false;
      bool done = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceRecordingCard(
              isRecording: true,
              formattedTime: '00:42',
              amplitude: 0.8,
              onRecord: () => recorded = true,
              onDone: () => done = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Recording Voice Note'), findsOneWidget);
      expect(find.text('00:42'), findsOneWidget);
      expect(find.text('Listening...'), findsOneWidget);

      final recordBtn = tester.widget<IconButton>(
        find.byKey(const Key('voice_recorder_record_button')),
      );
      // Disabled once started recording
      expect(recordBtn.onPressed, isNull);

      await tester.tap(find.byKey(const Key('voice_recorder_done_button')));
      expect(done, isTrue);

      await tester.tap(find.byKey(const Key('voice_recorder_delete_button')));
      expect(deleted, isTrue);
      expect(recorded, isFalse);
    });
  });
}
