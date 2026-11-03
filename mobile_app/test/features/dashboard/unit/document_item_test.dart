import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

void main() {
  group('DocumentItem Unit Tests', () {
    test('supports value comparisons via Equatable', () {
      const item1 = DocumentItem(
        id: '1',
        title: 'Report.pdf',
        type: DocumentType.pdf,
        fileSize: '2.0 MB',
        date: 'Oct 20',
        statusTag: 'Parsed',
      );
      const item2 = DocumentItem(
        id: '1',
        title: 'Report.pdf',
        type: DocumentType.pdf,
        fileSize: '2.0 MB',
        date: 'Oct 20',
        statusTag: 'Parsed',
      );

      expect(item1, equals(item2));
    });

    test('copyWith updates specified fields correctly', () {
      const original = DocumentItem(
        id: '1',
        title: 'Doc.pdf',
        type: DocumentType.pdf,
        fileSize: '1.0 MB',
        date: 'Oct 01',
        statusTag: 'Pending',
        isSelected: false,
      );

      final updated = original.copyWith(
        isSelected: true,
        statusTag: 'Parsed',
        isStatusHighlighted: true,
      );

      expect(updated.isSelected, isTrue);
      expect(updated.statusTag, 'Parsed');
      expect(updated.isStatusHighlighted, isTrue);
      expect(updated.title, 'Doc.pdf');
    });

    test('DashboardMetrics equality and properties', () {
      const metrics1 = DashboardMetrics(
        synthesizedDocsCount: 10,
        audioNotesHours: 2.5,
        confidencePercentage: 98.5,
      );
      const metrics2 = DashboardMetrics(
        synthesizedDocsCount: 10,
        audioNotesHours: 2.5,
        confidencePercentage: 98.5,
      );

      expect(metrics1, equals(metrics2));
      expect(metrics1.props, [10, 2.5, 98.5]);
    });
  });

  group('DashboardState Unit Tests', () {
    test('filteredDocuments filters correctly by category', () {
      const pdfDoc = DocumentItem(
        id: '1',
        title: 'Doc.pdf',
        type: DocumentType.pdf,
        fileSize: '1 MB',
        date: 'Today',
        statusTag: 'Parsed',
      );
      const audioDoc = DocumentItem(
        id: '2',
        title: 'Audio.wav',
        type: DocumentType.audio,
        fileSize: '5 MB',
        date: 'Today',
        statusTag: 'Transcribed',
      );
      const imageDoc = DocumentItem(
        id: '3',
        title: 'Photo.png',
        type: DocumentType.image,
        fileSize: '2 MB',
        date: 'Today',
        statusTag: 'OCR',
      );

      final state = const DashboardState(
        documents: [pdfDoc, audioDoc, imageDoc],
      );

      // All category
      expect(state.filteredDocuments.length, 3);

      // Reports category
      final reportsState =
          state.copyWith(selectedFilter: DocumentFilterCategory.reports);
      expect(reportsState.filteredDocuments, [pdfDoc]);

      // Recordings category
      final recordingsState =
          state.copyWith(selectedFilter: DocumentFilterCategory.recordings);
      expect(recordingsState.filteredDocuments, [audioDoc]);

      // Diagrams category
      final diagramsState =
          state.copyWith(selectedFilter: DocumentFilterCategory.diagrams);
      expect(diagramsState.filteredDocuments, [imageDoc]);
    });

    test('filteredDocuments filters case-insensitively by search query', () {
      const doc1 = DocumentItem(
        id: '1',
        title: 'Financial_Quarterly_Report.pdf',
        type: DocumentType.pdf,
        fileSize: '1 MB',
        date: 'Today',
        statusTag: 'Parsed',
      );
      const doc2 = DocumentItem(
        id: '2',
        title: 'Marketing_Meeting.wav',
        type: DocumentType.audio,
        fileSize: '1 MB',
        date: 'Today',
        statusTag: 'Voice Transcribed',
      );

      final state = const DashboardState(documents: [doc1, doc2]);

      final queryState = state.copyWith(searchQuery: 'financial');
      expect(queryState.filteredDocuments, [doc1]);

      final tagQueryState = state.copyWith(searchQuery: 'transcribed');
      expect(tagQueryState.filteredDocuments, [doc2]);
    });

    test('selectedCount and hasSelection reflect active selections accurately', () {
      const doc1 = DocumentItem(
        id: '1',
        title: 'A.pdf',
        type: DocumentType.pdf,
        fileSize: '1MB',
        date: 'Today',
        statusTag: 'OK',
        isSelected: true,
      );
      const doc2 = DocumentItem(
        id: '2',
        title: 'B.pdf',
        type: DocumentType.pdf,
        fileSize: '1MB',
        date: 'Today',
        statusTag: 'OK',
        isSelected: false,
      );

      final state = const DashboardState(documents: [doc1, doc2]);
      expect(state.selectedCount, 1);
      expect(state.hasSelection, isTrue);

      final emptySelectionState = const DashboardState(documents: [doc2]);
      expect(emptySelectionState.selectedCount, 0);
      expect(emptySelectionState.hasSelection, isFalse);
    });
  });
}
