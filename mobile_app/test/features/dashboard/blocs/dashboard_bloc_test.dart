import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:mobile_app/features/dashboard/repository/document_repository.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockDocumentRepository extends Mock implements IDocumentRepository {}

void main() {
  late MockDocumentRepository mockRepository;

  final sampleDocs = [
    const DocumentItem(
      id: 'doc_1',
      title: 'Doc1.pdf',
      type: DocumentType.pdf,
      fileSize: '1 MB',
      date: 'Oct 1',
      statusTag: 'Parsed',
      isSelected: false,
    ),
    const DocumentItem(
      id: 'doc_2',
      title: 'Doc2.png',
      type: DocumentType.image,
      fileSize: '2 MB',
      date: 'Oct 2',
      statusTag: 'OCR Ready',
      isSelected: true,
    ),
  ];

  const sampleMetrics = DashboardMetrics(
    synthesizedDocsCount: 15,
    audioNotesHours: 3.2,
    confidencePercentage: 99.1,
  );

  setUp(() {
    mockRepository = MockDocumentRepository();
  });

  group('DashboardBloc Tests', () {
    test('initial state has correct defaults', () {
      final bloc = DashboardBloc(repository: mockRepository);
      expect(bloc.state.status, DashboardStatus.initial);
      expect(bloc.state.documents, isEmpty);
      expect(bloc.state.selectedFilter, DocumentFilterCategory.all);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.currentNavIndex, 0);
    });

    blocTest<DashboardBloc, DashboardState>(
      'emits [loading, success] when LoadDashboardData succeeds',
      build: () {
        when(() => mockRepository.getDocuments())
            .thenAnswer((_) async => sampleDocs);
        when(() => mockRepository.getMetrics())
            .thenAnswer((_) async => sampleMetrics);
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadDashboardData()),
      expect: () => [
        const DashboardState(status: DashboardStatus.loading),
        DashboardState(
          status: DashboardStatus.success,
          documents: sampleDocs,
          metrics: sampleMetrics,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [loading, failure] when LoadDashboardData throws exception',
      build: () {
        when(() => mockRepository.getDocuments())
            .thenThrow(Exception('Failed to load documents'));
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadDashboardData()),
      expect: () => [
        const DashboardState(status: DashboardStatus.loading),
        predicate<DashboardState>((state) {
          return state.status == DashboardStatus.failure &&
              state.errorMessage != null;
        }),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'toggles isSelected state for target document',
      build: () => DashboardBloc(repository: mockRepository),
      seed: () => DashboardState(documents: sampleDocs),
      act: (bloc) => bloc.add(const ToggleDocumentSelection('doc_1')),
      expect: () => [
        DashboardState(
          documents: [
            sampleDocs[0].copyWith(isSelected: true),
            sampleDocs[1],
          ],
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'updates selectedFilter on ChangeFilterCategory event',
      build: () => DashboardBloc(repository: mockRepository),
      act: (bloc) =>
          bloc.add(const ChangeFilterCategory(DocumentFilterCategory.reports)),
      expect: () => [
        const DashboardState(selectedFilter: DocumentFilterCategory.reports),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'updates searchQuery on UpdateSearchQuery event',
      build: () => DashboardBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const UpdateSearchQuery('contract')),
      expect: () => [
        const DashboardState(searchQuery: 'contract'),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'clears all selected documents on ClearSelectedDocuments event',
      build: () => DashboardBloc(repository: mockRepository),
      seed: () => DashboardState(documents: sampleDocs),
      act: (bloc) => bloc.add(const ClearSelectedDocuments()),
      expect: () => [
        DashboardState(
          documents: [
            sampleDocs[0].copyWith(isSelected: false),
            sampleDocs[1].copyWith(isSelected: false),
          ],
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'updates currentNavIndex on ChangeNavigationTab event',
      build: () => DashboardBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ChangeNavigationTab(2)),
      expect: () => [
        const DashboardState(currentNavIndex: 2),
      ],
    );
  });
}
