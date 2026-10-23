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
      emit(state.copyWith(
        status: DashboardStatus.success,
        documents: documents,
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

    emit(state.copyWith(documents: updatedDocs));
  }

  void _onChangeNavigationTab(
    ChangeNavigationTab event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(currentNavIndex: event.tabIndex));
  }
}
