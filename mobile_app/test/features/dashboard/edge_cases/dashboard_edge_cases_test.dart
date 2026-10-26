import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:mobile_app/features/dashboard/repository/document_repository.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/dashboard/view/screens/dashboard_screen.dart';

class MockDocumentRepository extends Mock implements IDocumentRepository {}

void main() {
  late MockDocumentRepository mockRepository;

  final sampleDocs = [
    const DocumentItem(
      id: 'doc_1',
      title: 'alpha_contract.pdf',
      type: DocumentType.pdf,
      fileSize: '1 MB',
      date: 'Oct 1',
      statusTag: 'Parsed',
      isSelected: false,
    ),
    const DocumentItem(
      id: 'doc_2',
      title: 'beta_voice.wav',
      type: DocumentType.audio,
      fileSize: '2 MB',
      date: 'Oct 2',
      statusTag: 'Transcribed',
      isSelected: false,
    ),
  ];

  const defaultMetrics = DashboardMetrics(
    synthesizedDocsCount: 2,
    audioNotesHours: 1.0,
    confidencePercentage: 99.0,
  );

  setUp(() {
    mockRepository = MockDocumentRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<IDocumentRepository>.value(
      value: mockRepository,
      child: BlocProvider<DashboardBloc>(
        create: (_) => DashboardBloc(repository: mockRepository),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );
  }

  group('Dashboard Edge Cases Tests', () {
    testWidgets(
        'displays empty state message when repository returns 0 documents',
        (tester) async {
      when(() => mockRepository.getDocuments()).thenAnswer((_) async => []);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No documents found'), findsOneWidget);
      expect(find.text('Try clearing filters or search query'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets(
        'tapping clickable search bar navigates to Semantic Search screen',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsOneWidget);

      // Tapping search bar placeholder navigates to Search screen
      final searchBar =
          find.text('Search across all documents, images, and voice...');
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      expect(find.text('Semantic Search'), findsOneWidget);
      expect(find.text('Search Scope:'), findsNothing);
    });

    testWidgets('search with special characters does not crash',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter special regex characters via bloc
      tester
          .element(find.byType(DashboardScreen))
          .read<DashboardBloc>()
          .add(const UpdateSearchQuery(r'[.*+?^${}()|[\]\\]'));
      await tester.pumpAndSettle();

      expect(find.text('No documents found'), findsOneWidget);
    });

    testWidgets('whitespace-only search preserves full list of documents',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      tester
          .element(find.byType(DashboardScreen))
          .read<DashboardBloc>()
          .add(const UpdateSearchQuery('     '));
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsOneWidget);
      expect(find.text('beta_voice.wav'), findsOneWidget);
    });

    testWidgets(
        'filtering by category chips (All, Documents, Recordings, Images) filters document list',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsOneWidget);
      expect(find.text('beta_voice.wav'), findsOneWidget);

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsOneWidget);
      expect(find.text('beta_voice.wav'), findsNothing);

      await tester.tap(find.text('Recordings'));
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsNothing);
      expect(find.text('beta_voice.wav'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('alpha_contract.pdf'), findsOneWidget);
      expect(find.text('beta_voice.wav'), findsOneWidget);
    });

    testWidgets('multiple document selections show correct batch count and hide on deselect',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially no batch bar
      expect(find.text('1 file selected'), findsNothing);

      // Select first document
      await tester.tap(find.text('alpha_contract.pdf'));
      await tester.pumpAndSettle();

      expect(find.text('1 file selected'), findsOneWidget);
      expect(find.text('1 SELECTED'), findsOneWidget);

      // Select second document
      await tester.tap(find.text('beta_voice.wav'));
      await tester.pumpAndSettle();

      expect(find.text('2 files selected'), findsOneWidget);
      expect(find.text('2 SELECTED'), findsOneWidget);

      // Deselect both
      await tester.tap(find.text('alpha_contract.pdf'));
      await tester.tap(find.text('beta_voice.wav'));
      await tester.pumpAndSettle();

      expect(find.text('files selected'), findsNothing);
      expect(find.text('SELECTED'), findsNothing);
    });

    testWidgets('tapping sort filter icon opens sort bottom sheet',
        (tester) async {
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => sampleDocs);
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => defaultMetrics);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Sort by Name'), findsOneWidget);
      expect(find.text('Sort by Date Added'), findsOneWidget);
      expect(find.text('Sort by File Size'), findsOneWidget);
    });
  });
}
