import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/preview/file_preview_modal.dart';
import '../../../upload/view/screens/upload_screen.dart';
import '../../blocs/dashboard_bloc.dart';
import '../../blocs/dashboard_event.dart';
import '../../blocs/dashboard_state.dart';
import '../../repository/models/document_item.dart';
import '../widgets/dashboard_fab.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/document_card.dart';
import '../widgets/filter_chips_row.dart';

/// Tab 0: Self-contained Dashboard & Library View screen with its own Scaffold,
/// dedicated TopBar, and local FloatingActionButton (+ New Upload).
class DashboardLibraryView extends StatefulWidget {
  const DashboardLibraryView({super.key});

  @override
  State<DashboardLibraryView> createState() => _DashboardLibraryViewState();
}

class _DashboardLibraryViewState extends State<DashboardLibraryView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          appBar: DashboardTopBar(
            onProfileTap: () => _showMoreOptionsModal(context),
            onOptionsTap: () => _showMoreOptionsModal(context),
          ),
          floatingActionButton: !state.isSelectionMode
              ? DashboardFab(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadScreen()),
                    );
                  },
                )
              : null,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fixed top section: Category Filter Chips & Library Header (never scrolls)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Filter Category Chips (Top prominent filter)
                        FilterChipsRow(
                          selectedCategory: state.selectedFilter,
                          onSelected: (cat) {
                            context
                                .read<DashboardBloc>()
                                .add(ChangeFilterCategory(cat));
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. Section Header: My Library & Selection Actions
                        _buildLibraryHeader(context, state),
                      ],
                    ),
                  ),

                  // 3. Document files: static widget if empty, scrollable ListView if populated
                  Expanded(
                    child: state.filteredDocuments.isEmpty
                        ? _buildDocumentList(context, state)
                        : RefreshIndicator(
                            color: AppColors.secondary,
                            backgroundColor: AppColors.surfaceContainerLowest,
                            onRefresh: () async {
                              context
                                  .read<DashboardBloc>()
                                  .add(const LoadDashboardData());
                            },
                            child: _buildDocumentList(context, state),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLibraryHeader(BuildContext context, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title & Files Count
        Row(
          children: [
            Text(
              'My Library',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                AppFormatters.formatCountWithNoun(state.documents.length, 'file'),
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Actions: Select / Cancel Toggle & Sort Button
        Row(
          children: [
            TextButton(
              onPressed: () {
                context.read<DashboardBloc>().add(
                      ToggleSelectionMode(!state.isSelectionMode),
                    );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                state.isSelectionMode ? 'Cancel' : 'Select',
                style: AppTypography.labelMd.copyWith(
                  color: state.isSelectionMode
                      ? AppColors.error
                      : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                _showSortModal(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentList(BuildContext context, DashboardState state) {
    final filtered = state.filteredDocuments;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                color: AppColors.outline,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'No documents found',
                style: AppTypography.titleSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try clearing filters or search query',
                style: AppTypography.bodySm,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return DocumentCard(
          item: item,
          isSelectionMode: state.isSelectionMode,
          onTap: () {
            if (state.isSelectionMode) {
              context
                  .read<DashboardBloc>()
                  .add(ToggleDocumentSelection(item.id));
            } else {
              FilePreviewModal.show(
                context,
                title: item.title,
                type: item.type,
              );
            }
          },
          onToggleSelect: () {
            context
                .read<DashboardBloc>()
                .add(ToggleDocumentSelection(item.id));
          },
          onLongPress: () {
            if (!state.isSelectionMode) {
              context.read<DashboardBloc>().add(const ToggleSelectionMode(true));
              context.read<DashboardBloc>().add(ToggleDocumentSelection(item.id));
            }
          },
          onMoreTap: () {
            _showItemOptionsModal(context, item);
          },
        );
      },
    );
  }

  void _showMoreOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Workspace Settings'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_sync_outlined),
                title: const Text('Storage & Sync'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Feedback'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Log Out',
                    style: TextStyle(color: AppColors.error)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Sort by Name'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Sort by Date Added'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.data_usage),
                title: const Text('Sort by File Size'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptionsModal(BuildContext context, DocumentItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  item.title,
                  style: AppTypography.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View Document Preview'),
                onTap: () {
                  Navigator.pop(ctx);
                  FilePreviewModal.show(
                    context,
                    title: item.title,
                    type: item.type,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('Chat with this Document'),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<DashboardBloc>()
                      .add(const ChangeNavigationTab(2));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete Document',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<DashboardBloc>()
                      .add(ToggleDocumentSelection(item.id));
                  context
                      .read<DashboardBloc>()
                      .add(const DeleteSelectedDocuments());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
