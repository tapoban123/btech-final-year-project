import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/widgets/preview/audio_previewer.dart';

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

    when(() => mockPlayer.play(any())).thenAnswer((_) async {});
    when(() => mockPlayer.pause()).thenAnswer((_) async {});
    when(() => mockPlayer.seek(any())).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateCtrl.close();
    posCtrl.close();
    durCtrl.close();
    compCtrl.close();
  });

  group('AudioPreviewer Widget Tests', () {
    testWidgets('renders fallback when file does not exist and no player is provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioPreviewer(
              filePath: '/invalid/path/audio.mp3',
              title: 'Voice_Note.mp3',
            ),
          ),
        ),
      );

      expect(find.text('Voice_Note.mp3'), findsOneWidget);
      expect(
        find.text('Audio preview unavailable (file path not found)'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.mic_none_outlined), findsOneWidget);
    });

    testWidgets('renders player controls with slider and timestamps',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioPreviewer(
              filePath: '/path/recording.m4a',
              title: 'Meeting.m4a',
              player: mockPlayer,
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byKey(const Key('audio_preview_play_pause_button')), findsOneWidget);
      expect(find.byKey(const Key('audio_preview_slider')), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Emit duration: 60s, position: 15s
      durCtrl.add(const Duration(seconds: 60));
      posCtrl.add(const Duration(seconds: 15));
      await tester.pump();

      expect(find.text('00:15'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);
    });

    testWidgets('toggles play/pause when play button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioPreviewer(
              filePath: '/path/recording.m4a',
              title: 'Meeting.m4a',
              player: mockPlayer,
            ),
          ),
        ),
      );

      // Tap play
      await tester.tap(find.byKey(const Key('audio_preview_play_pause_button')));
      await tester.pump();

      verify(() => mockPlayer.play(any())).called(1);

      // Simulate playing state
      stateCtrl.add(PlayerState.playing);
      await tester.pump();

      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap pause
      await tester.tap(find.byKey(const Key('audio_preview_play_pause_button')));
      await tester.pump();

      verify(() => mockPlayer.pause()).called(1);
    });

    testWidgets('dragging slider triggers player seek', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioPreviewer(
              filePath: '/path/recording.m4a',
              title: 'Meeting.m4a',
              player: mockPlayer,
            ),
          ),
        ),
      );

      durCtrl.add(const Duration(seconds: 100));
      await tester.pump();

      final slider = find.byKey(const Key('audio_preview_slider'));
      expect(slider, findsOneWidget);

      // Drag slider
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      verify(() => mockPlayer.seek(any())).called(1);
    });

    testWidgets('tapping on waveform bar seeks to corresponding time offset',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioPreviewer(
              filePath: '/path/recording.m4a',
              title: 'Meeting.m4a',
              player: mockPlayer,
            ),
          ),
        ),
      );

      durCtrl.add(const Duration(seconds: 120));
      await tester.pump();

      final waveformBars = find.byType(AnimatedContainer);
      expect(waveformBars, findsWidgets);

      await tester.tap(waveformBars.at(14));
      await tester.pump();

      verify(() => mockPlayer.seek(any())).called(1);
    });
  });
}
