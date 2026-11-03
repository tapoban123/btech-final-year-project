import 'package:equatable/equatable.dart';
import '../repository/models/document_item.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class ToggleDocumentSelection extends DashboardEvent {
  final String documentId;

  const ToggleDocumentSelection(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class ChangeFilterCategory extends DashboardEvent {
  final DocumentFilterCategory category;

  const ChangeFilterCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateSearchQuery extends DashboardEvent {
  final String query;

  const UpdateSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSelectedDocuments extends DashboardEvent {
  const ClearSelectedDocuments();
}

class ToggleSelectionMode extends DashboardEvent {
  final bool? isEnabled;

  const ToggleSelectionMode([this.isEnabled]);

  @override
  List<Object?> get props => [isEnabled];
}

class DeleteSelectedDocuments extends DashboardEvent {
  const DeleteSelectedDocuments();
}

class ChangeNavigationTab extends DashboardEvent {
  final int tabIndex;

  const ChangeNavigationTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

