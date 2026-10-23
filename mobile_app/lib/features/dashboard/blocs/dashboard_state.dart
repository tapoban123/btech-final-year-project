import 'package:equatable/equatable.dart';
import '../repository/models/document_item.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<DocumentItem> documents;
  final DashboardMetrics metrics;
  final DocumentFilterCategory selectedFilter;
  final String searchQuery;
  final int currentNavIndex;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.documents = const [],
    this.metrics = const DashboardMetrics(
      synthesizedDocsCount: 24,
      audioNotesHours: 4.8,
      confidencePercentage: 99.4,
    ),
    this.selectedFilter = DocumentFilterCategory.all,
    this.searchQuery = '',
    this.currentNavIndex = 0,
    this.errorMessage,
  });

  int get selectedCount => documents.where((doc) => doc.isSelected).length;

  bool get hasSelection => selectedCount > 0;

  List<DocumentItem> get filteredDocuments {
    return documents.where((doc) {
      // 1. Filter by category
      bool matchesCategory = true;
      switch (selectedFilter) {
        case DocumentFilterCategory.reports:
          matchesCategory = doc.type == DocumentType.pdf || doc.type == DocumentType.docx;
          break;
        case DocumentFilterCategory.recordings:
          matchesCategory = doc.type == DocumentType.audio;
          break;
        case DocumentFilterCategory.diagrams:
          matchesCategory = doc.type == DocumentType.image;
          break;
        case DocumentFilterCategory.all:
          matchesCategory = true;
          break;
      }

      // 2. Filter by search query
      final matchesSearch = searchQuery.trim().isEmpty ||
          doc.title.toLowerCase().contains(searchQuery.toLowerCase().trim()) ||
          doc.statusTag.toLowerCase().contains(searchQuery.toLowerCase().trim());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  DashboardState copyWith({
    DashboardStatus? status,
    List<DocumentItem>? documents,
    DashboardMetrics? metrics,
    DocumentFilterCategory? selectedFilter,
    String? searchQuery,
    int? currentNavIndex,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      metrics: metrics ?? this.metrics,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        documents,
        metrics,
        selectedFilter,
        searchQuery,
        currentNavIndex,
        errorMessage,
      ];
}
