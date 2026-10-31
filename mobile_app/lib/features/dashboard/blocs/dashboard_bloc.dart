import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/document_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final IDocumentRepository _repository;

  DashboardBloc({IDocumentRepository? repository})
      : _repository = repository ?? DocumentRepository(),
        super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<ToggleDocumentSelection>(_onToggleDocumentSelection);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<DeleteSelectedDocuments>(_onDeleteSelectedDocuments);
    on<ChangeFilterCategory>(_onChangeFilterCategory);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<ClearSelectedDocuments>(_onClearSelectedDocuments);
    on<ChangeNavigationTab>(_onChangeNavigationTab);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final documents = await _repository.getDocuments();
      final metrics = await _repository.getMetrics();
      final cleanDocs =
          documents.map((doc) => doc.copyWith(isSelected: false)).toList();
      emit(state.copyWith(
        status: DashboardStatus.success,
        documents: cleanDocs,
        isSelectionMode: false,
        metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleDocumentSelection(
    ToggleDocumentSelection event,
    Emitter<DashboardState> emit,
  ) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.id == event.documentId) {
        return doc.copyWith(isSelected: !doc.isSelected);
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocs));
  }

  void _onToggleSelectionMode(
    ToggleSelectionMode event,
    Emitter<DashboardState> emit,
  ) {
    final nextMode = event.isEnabled ?? !state.isSelectionMode;
    // Always clear any selection state so zero selection is default
    // and selection does not persist when mode is off or toggled
    final updatedDocs =
        state.documents.map((doc) => doc.copyWith(isSelected: false)).toList();
    emit(state.copyWith(
      isSelectionMode: nextMode,
      documents: updatedDocs,
    ));
  }

  void _onDeleteSelectedDocuments(
    DeleteSelectedDocuments event,
    Emitter<DashboardState> emit,
  ) {
    final remainingDocs =
        state.documents.where((doc) => !doc.isSelected).toList();
    emit(state.copyWith(documents: remainingDocs, isSelectionMode: false));
  }

  void _onChangeFilterCategory(
    ChangeFilterCategory event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedFilter: event.category));
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearSelectedDocuments(
    ClearSelectedDocuments event,
    Emitter<DashboardState> emit,
  ) {
    final updatedDocs = state.documents.map((doc) {
      return doc.copyWith(isSelected: false);
    }).toList();

    emit(state.copyWith(documents: updatedDocs, isSelectionMode: false));
  }

  void _onChangeNavigationTab(
    ChangeNavigationTab event,
    Emitter<DashboardState> emit,
  ) {
    if (state.isSelectionMode) {
      final updatedDocs =
          state.documents.map((doc) => doc.copyWith(isSelected: false)).toList();
      emit(state.copyWith(
        currentNavIndex: event.tabIndex,
        isSelectionMode: false,
        documents: updatedDocs,
      ));
      return;
    }
    emit(state.copyWith(currentNavIndex: event.tabIndex));
  }
}


