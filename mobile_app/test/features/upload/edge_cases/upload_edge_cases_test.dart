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

class MockUploadRepository extends Mock implements IUploadRepository {}

class MockFilePickerService extends Mock implements IFilePickerService {}

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
  late FakePlatformFile mockFile;

  setUp(() {
    mockRepository = MockUploadRepository();
    mockFilePicker = MockFilePickerService();
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
        create: (_) => UploadBloc(repository: mockRepository),
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
      expect(find.text('0 Active'), findsOneWidget);
      expect(find.text('No uploads yet'), findsOneWidget);
      expect(find.text('Confirm Upload'), findsOneWidget);
    });

    testWidgets(
        'tapping Upload Files opens format selection modal and triggers upload',
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
          stageDescription: 'Processing',
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

      verify(() => mockRepository.uploadFile(
            'Annual_Financial_Report.pdf',
            DocumentType.pdf,
            filePath: any(named: 'filePath'),
            fileSize: any(named: 'fileSize'),
          )).called(1);

      // Verify sticky confirm button shows item count
      expect(find.text('Confirm Upload (1)'), findsOneWidget);
    });

    testWidgets(
        'multi-select of images adds all selected files to upload list and updates confirm button',
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
          stageDescription: 'Queued',
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

    testWidgets('tapping Save & Ingest stops recording and persists item',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockRepository.saveVoiceMemo(any())).thenAnswer(
        (_) async => const UploadItem(
          id: 'memo_saved',
          title: 'Voice_Memo.m4a',
          type: DocumentType.audio,
          stageDescription: 'Transcribing',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Voice card is not visible initially
      expect(find.text('Recording Voice Memo'), findsNothing);

      // Tap Record Voice Note to begin
      await tester.tap(find.text('Record Voice Note'));
      await tester.pumpAndSettle();

      expect(find.text('Recording Voice Memo'), findsOneWidget);

      await tester.tap(find.text('Save & Ingest'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVoiceMemo(any())).called(1);
      expect(find.text('Recording Voice Memo'), findsNothing);
    });

    testWidgets('tapping cancel on VoiceRecordingCard dismisses recording',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Record Voice Note
      await tester.tap(find.text('Record Voice Note'));
      await tester.pumpAndSettle();

      expect(find.text('Recording Voice Memo'), findsOneWidget);

      // Tap cancel close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Recording Voice Memo'), findsNothing);
      verifyNever(() => mockRepository.saveVoiceMemo(any()));
    });
  });
}
