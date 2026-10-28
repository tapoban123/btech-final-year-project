import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/blocs/upload_bloc.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/repository/upload_repository.dart';
import 'package:mobile_app/features/upload/services/file_picker_service.dart';
import 'package:mobile_app/features/upload/view/screens/upload_screen.dart';

import 'package:mobile_app/features/upload/services/audio_recording_service.dart';

class MockUploadRepository extends Mock implements IUploadRepository {}

class MockFilePickerService extends Mock implements IFilePickerService {}

class MockAudioRecordingService extends Mock implements IAudioRecordingService {}

base class FakePlatformFile extends PlatformFile {
  FakePlatformFile({
    required this.name,
    required String path,
    this.fileSize = 1048576,
  }) : uri = Uri.file(path);

  @override
  final String name;

  @override
  final Uri uri;

  final int fileSize;

  @override
  XFile get xFile => XFile(path ?? '');

  @override
  int? lengthSync() => fileSize;

  @override
  Future<int?> length() async => fileSize;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();
}

void main() {
  setUpAll(() {
    registerFallbackValue(FileType.any);
    registerFallbackValue(DocumentType.pdf);
  });

  late MockUploadRepository mockRepository;
  late MockFilePickerService mockFilePicker;
  late MockAudioRecordingService mockAudioService;
  late FakePlatformFile mockFile;

  setUp(() {
    mockRepository = MockUploadRepository();
    mockFilePicker = MockFilePickerService();
    mockAudioService = MockAudioRecordingService();
    when(() => mockAudioService.hasPermission()).thenAnswer((_) async => true);
    when(() => mockAudioService.start(path: any(named: 'path')))
        .thenAnswer((_) async {});
    when(() => mockAudioService.stop())
        .thenAnswer((_) async => '/tmp/memo.m4a');
    when(() => mockAudioService.cancel()).thenAnswer((_) async {});
    when(() => mockAudioService.onAmplitudeChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAudioService.isRecording()).thenAnswer((_) async => false);

    mockFile = FakePlatformFile(
      name: 'Annual_Financial_Report.pdf',
      path: '/docs/Annual_Financial_Report.pdf',
      fileSize: 1048576,
    );
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<IUploadRepository>.value(
      value: mockRepository,
      child: BlocProvider<UploadBloc>(
        create: (_) => UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        ),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: UploadScreen(filePickerService: mockFilePicker),
        ),
      ),
    );
  }

  group('Upload Edge Cases Tests', () {
    testWidgets('handles empty recent uploads gracefully', (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Upload Documents'), findsOneWidget);
      expect(find.text('Recent Uploads'), findsOneWidget);
      expect(find.text('No uploads yet'), findsOneWidget);
      expect(find.text('Confirm Upload'), findsOneWidget);
    });

    testWidgets(
        'tapping Upload Files opens format selection modal and stages item until confirm upload is clicked',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          )).thenAnswer((_) async => [mockFile]);

      when(() => mockRepository.uploadFile(
            'Annual_Financial_Report.pdf',
            DocumentType.pdf,
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).thenAnswer(
        (_) async => const UploadItem(
          id: 'up_annual',
          title: 'Annual_Financial_Report.pdf',
          type: DocumentType.pdf,
          stageDescription: 'Indexed & ready',
          status: UploadProcessingStatus.completed,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload Files'));
      await tester.pumpAndSettle();

      // Verify only 3 buttons are rendered (no fourth button)
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Browse All Supported Files'), findsNothing);

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Staged in list - uploadFile NOT called yet
      verifyNever(() => mockRepository.uploadFile(
            any(),
            any(),
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          ));

      // Verify sticky confirm button shows item count
      expect(find.text('Confirm Upload (1)'), findsOneWidget);
      expect(find.text('Annual_Financial_Report.pdf'), findsOneWidget);

      // Tap confirm upload
      await tester.tap(find.text('Confirm Upload (1)'));
      await tester.pumpAndSettle();

      // Now uploadFile was executed
      verify(() => mockRepository.uploadFile(
            'Annual_Financial_Report.pdf',
            DocumentType.pdf,
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).called(1);
    });

    testWidgets(
        'multi-select of images stages files and uploads them in parallel when confirm upload is tapped',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      final imageFile1 = FakePlatformFile(
        name: 'architecture_diagram.png',
        path: '/photos/architecture_diagram.png',
        fileSize: 2048576,
      );
      final imageFile2 = FakePlatformFile(
        name: 'database_schema.jpg',
        path: '/photos/database_schema.jpg',
        fileSize: 1548576,
      );

      when(() => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          )).thenAnswer((_) async => [imageFile1, imageFile2]);

      when(() => mockRepository.uploadFile(
            any(),
            any(),
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).thenAnswer(
        (inv) async => UploadItem(
          id: 'up_${inv.positionalArguments[0]}',
          title: inv.positionalArguments[0] as String,
          type: inv.positionalArguments[1] as DocumentType,
          stageDescription: 'Indexed & ready',
          status: UploadProcessingStatus.completed,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload Files'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Images'));
      await tester.pumpAndSettle();

      expect(find.text('architecture_diagram.png'), findsOneWidget);
      expect(find.text('database_schema.jpg'), findsOneWidget);
      expect(find.text('Confirm Upload (2)'), findsOneWidget);

      // Verify not yet uploaded
      verifyNever(() => mockRepository.uploadFile(
            any(),
            any(),
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          ));

      // Tap Confirm Upload (2)
      await tester.tap(find.text('Confirm Upload (2)'));
      await tester.pumpAndSettle();

      // Verify both files uploaded in parallel
      verify(() => mockRepository.uploadFile(
            'architecture_diagram.png',
            DocumentType.image,
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).called(1);
      verify(() => mockRepository.uploadFile(
            'database_schema.jpg',
            DocumentType.image,
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).called(1);
    });

    testWidgets(
        'tapping delete button removes item from staged list and updates confirm button count',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      final imageFile1 = FakePlatformFile(
        name: 'architecture_diagram.png',
        path: '/photos/architecture_diagram.png',
        fileSize: 2048576,
      );
      final imageFile2 = FakePlatformFile(
        name: 'database_schema.jpg',
        path: '/photos/database_schema.jpg',
        fileSize: 1548576,
      );

      when(() => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          )).thenAnswer((_) async => [imageFile1, imageFile2]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload Files'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Images'));
      await tester.pumpAndSettle();

      expect(find.text('architecture_diagram.png'), findsOneWidget);
      expect(find.text('database_schema.jpg'), findsOneWidget);
      expect(find.text('Confirm Upload (2)'), findsOneWidget);

      // Tap delete on first item
      final deleteButtons = find.byIcon(Icons.close);
      expect(deleteButtons, findsNWidgets(2));

      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Now only 1 item left
      expect(find.text('Confirm Upload (1)'), findsOneWidget);
      expect(find.text('architecture_diagram.png'), findsNothing);
      expect(find.text('database_schema.jpg'), findsOneWidget);

      // Tap delete on remaining item
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // List is empty
      expect(find.text('No uploads yet'), findsOneWidget);
      expect(find.text('Confirm Upload'), findsOneWidget);
    });

    testWidgets('canceling file selection does not trigger upload',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          )).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload Files'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Images'));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepository.uploadFile(
            any(),
            any(),
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          ));
      expect(find.text('Confirm Upload'), findsOneWidget);
    });

    testWidgets(
        'voice recorder flow: opens on tap, starts on tap to speak, and stages memo on done',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockRepository.saveVoiceMemo(any())).thenAnswer(
        (_) async => const UploadItem(
          id: 'memo_saved',
          title: 'Voice_Memo.m4a',
          type: DocumentType.audio,
          stageDescription: '00:45',
          status: UploadProcessingStatus.completed,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Voice card is not visible initially
      expect(find.text('Voice Note'), findsNothing);

      // Tap Record Voice Note to open recorder widget
      await tester.tap(find.text('Record Voice Note'));
      await tester.pumpAndSettle();

      expect(find.text('Voice Note'), findsOneWidget);
      expect(find.text('Tap mic to speak'), findsOneWidget);

      // Tap mic / tap to speak button to start recording
      await tester.tap(find.byKey(const Key('voice_recorder_record_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockAudioService.hasPermission()).called(1);
      verify(() => mockAudioService.start(path: any(named: 'path'))).called(1);
      expect(find.text('Recording Voice Note'), findsOneWidget);
      expect(find.text('Listening...'), findsOneWidget);

      // Tap check / done button to finish recording
      await tester.tap(find.byKey(const Key('voice_recorder_done_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      verify(() => mockAudioService.stop()).called(1);
      verify(() => mockRepository.saveVoiceMemo(any())).called(1);
      expect(find.text('Voice Note'), findsNothing);
      expect(find.text('Voice_Memo.m4a'), findsOneWidget);
      expect(find.text('Confirm Upload (1)'), findsOneWidget);
    });

    testWidgets('tapping delete button on VoiceRecordingCard dismisses recording',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Record Voice Note
      await tester.tap(find.text('Record Voice Note'));
      await tester.pumpAndSettle();

      expect(find.text('Voice Note'), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byKey(const Key('voice_recorder_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Voice Note'), findsNothing);
      verify(() => mockAudioService.cancel()).called(1);
      verifyNever(() => mockRepository.saveVoiceMemo(any()));
    });

    testWidgets('denied microphone permission shows error and aborts recording',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockAudioService.hasPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Record Voice Note'));
      await tester.pumpAndSettle();

      expect(find.text('Voice Note'), findsOneWidget);

      await tester.tap(find.byKey(const Key('voice_recorder_record_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Microphone permission is required to record voice notes'),
        findsOneWidget,
      );
      verifyNever(() => mockAudioService.start(path: any(named: 'path')));
    });
  });
}
