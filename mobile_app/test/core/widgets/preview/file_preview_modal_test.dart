import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/widgets/preview/audio_previewer.dart';
import 'package:mobile_app/core/widgets/preview/file_preview_modal.dart';
import 'package:mobile_app/core/widgets/preview/image_previewer.dart';
import 'package:mobile_app/core/widgets/preview/pdf_previewer.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(DeviceFileSource(''));
  });

  late MockAudioPlayer mockPlayer;
  late StreamController<PlayerState> stateCtrl;
  late StreamController<Duration> posCtrl;
  late StreamController<Duration> durCtrl;
  late StreamController<void> compCtrl;

  setUp(() {
    mockPlayer = MockAudioPlayer();
    stateCtrl = StreamController<PlayerState>.broadcast();
    posCtrl = StreamController<Duration>.broadcast();
    durCtrl = StreamController<Duration>.broadcast();
    compCtrl = StreamController<void>.broadcast();

    when(() => mockPlayer.onPlayerStateChanged).thenAnswer((_) => stateCtrl.stream);
    when(() => mockPlayer.onPositionChanged).thenAnswer((_) => posCtrl.stream);
    when(() => mockPlayer.onDurationChanged).thenAnswer((_) => durCtrl.stream);
    when(() => mockPlayer.onPlayerComplete).thenAnswer((_) => compCtrl.stream);
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateCtrl.close();
    posCtrl.close();
    durCtrl.close();
    compCtrl.close();
  });

  group('FilePreviewModal Widget Tests', () {
    testWidgets('renders ImagePreviewer for DocumentType.image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FilePreviewModal(
              title: 'Screenshot.png',
              type: DocumentType.image,
            ),
          ),
        ),
      );

      expect(find.text('Screenshot.png'), findsAtLeastNWidgets(1));
      expect(find.text('Preview mode'), findsOneWidget);
      expect(find.byType(ImagePreviewer), findsOneWidget);
      expect(find.byKey(const Key('close_preview_modal_button')), findsOneWidget);
    });

    testWidgets('renders AudioPreviewer for DocumentType.audio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePreviewModal(
              title: 'VoiceMemo.m4a',
              type: DocumentType.audio,
              player: mockPlayer,
            ),
          ),
        ),
      );

      expect(find.text('VoiceMemo.m4a'), findsAtLeastNWidgets(1));
      expect(find.byType(AudioPreviewer), findsOneWidget);
    });

    testWidgets('renders PdfPreviewer for DocumentType.pdf', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FilePreviewModal(
              title: 'Contract.pdf',
              type: DocumentType.pdf,
            ),
          ),
        ),
      );

      expect(find.text('Contract.pdf'), findsAtLeastNWidgets(1));
      expect(find.byType(PdfPreviewer), findsOneWidget);
    });

    testWidgets('FilePreviewModal.show opens modal and close button dismisses it',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FilePreviewModal.show(
                      context,
                      title: 'Sample.png',
                      type: DocumentType.image,
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Sample.png'), findsAtLeastNWidgets(1));
      expect(find.text('Preview mode'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const Key('close_preview_modal_button')));
      await tester.pumpAndSettle();

      expect(find.text('Preview mode'), findsNothing);
    });
  });
}
