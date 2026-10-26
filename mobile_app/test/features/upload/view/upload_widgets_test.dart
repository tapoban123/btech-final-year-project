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
      bool optionsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: UploadHeader(
              onBackTap: () => backTapped = true,
              onOptionsTap: () => optionsTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add New Knowledge'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backTapped, isTrue);

      await tester.tap(find.byIcon(Icons.more_vert));
      expect(optionsTapped, isTrue);
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

    testWidgets('RecentUploadsCard renders active count and items',
        (tester) async {
      const items = [
        UploadItem(
          id: '1',
          title: 'Contract_2025.pdf',
          type: DocumentType.pdf,
          stageDescription: 'Analyzing semantic vectors',
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
      expect(find.text('1 Active'), findsOneWidget);
      expect(find.text('Contract_2025.pdf'), findsOneWidget);
      expect(find.text('Analyzing semantic vectors'), findsOneWidget);
      expect(find.text('Processing...'), findsOneWidget);
    });

    testWidgets('VoiceRecordingCard renders waveform and triggers Save & Ingest',
        (tester) async {
      bool saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceRecordingCard(
              isRecording: true,
              formattedTime: '02:45',
              statusMessage:
                  'Speech detected: Multimodal vector ingestion live',
              onSaveAndIngest: () => saved = true,
            ),
          ),
        ),
      );

      expect(find.text('Recording Voice Memo'), findsOneWidget);
      expect(find.text('02:45'), findsOneWidget);
      expect(
        find.text('Speech detected: Multimodal vector ingestion live'),
        findsOneWidget,
      );
      expect(find.text('Save & Ingest'), findsOneWidget);

      await tester.tap(find.text('Save & Ingest'));
      expect(saved, isTrue);
    });
  });
}
