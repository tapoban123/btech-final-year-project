import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/blocs/upload_bloc.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/repository/upload_repository.dart';
import 'package:mobile_app/features/upload/view/screens/upload_screen.dart';

class MockUploadRepository extends Mock implements IUploadRepository {}

void main() {
  late MockUploadRepository mockRepository;

  setUp(() {
    mockRepository = MockUploadRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<IUploadRepository>.value(
      value: mockRepository,
      child: BlocProvider<UploadBloc>(
        create: (_) => UploadBloc(repository: mockRepository),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const UploadScreen(),
        ),
      ),
    );
  }

  group('Upload Edge Cases Tests', () {
    testWidgets('handles empty recent uploads gracefully', (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Add New Knowledge'), findsOneWidget);
      expect(find.text('0 Active'), findsOneWidget);
    });

    testWidgets('tapping Upload Files opens format selection modal and triggers upload',
        (tester) async {
      when(() => mockRepository.getRecentUploads()).thenAnswer((_) async => []);
      when(() => mockRepository.uploadFile('Annual_Financial_Report.pdf', DocumentType.pdf))
          .thenAnswer(
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

      expect(find.text('Upload PDF Document'), findsOneWidget);
      expect(find.text('Upload Image / Diagram'), findsOneWidget);
      expect(find.text('Upload Audio Recording'), findsOneWidget);

      await tester.tap(find.text('Upload PDF Document'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.uploadFile('Annual_Financial_Report.pdf', DocumentType.pdf))
          .called(1);
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

      await tester.tap(find.text('Save & Ingest'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVoiceMemo(any())).called(1);
    });
  });
}
