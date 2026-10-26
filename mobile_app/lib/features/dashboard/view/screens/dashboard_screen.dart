import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../chat/blocs/chat_bloc.dart';
import '../../../chat/view/screens/chat_screen.dart';
import '../../../search/view/screens/search_screen.dart';
import '../../../upload/view/screens/upload_screen.dart';
import '../../blocs/dashboard_bloc.dart';
import '../../blocs/dashboard_event.dart';
import '../../blocs/dashboard_state.dart';
import '../widgets/batch_action_bar.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_fab.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/document_card.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/multimodal_search_bar.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
          body: IndexedStack(
            index: state.currentNavIndex,
            children: [
              // Tab 0: Home / Library View
              _buildHomeTab(context, state),

              // Tab 1: Semantic Search & Similarity View
              SearchScreen(
                onNavigateToTab: (idx) {
                  context.read<DashboardBloc>().add(ChangeNavigationTab(idx));
                },
              ),

              // Tab 2: AI Chat & RAG Assistant
              Builder(
                builder: (ctx) {
                  try {
                    ctx.read<ChatBloc>();
                    return ChatScreen(
                      showBottomNav: false,
                      onBackTap: () {
                        context
                            .read<DashboardBloc>()
                            .add(const ChangeNavigationTab(0));
                      },
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: state.currentNavIndex == 0
              ? DashboardFab(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadScreen()),
                    );
                  },
                )
              : null,
          bottomNavigationBar: DashboardBottomNav(
            currentIndex: state.currentNavIndex,
            onTabSelected: (index) {
              context.read<DashboardBloc>().add(ChangeNavigationTab(index));
            },
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(BuildContext context, DashboardState state) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: DashboardTopBar(
        onProfileTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Executive Profile: ED (Administrator)'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onOptionsTap: () {
          _showMoreOptionsModal(context);
        },
      ),
      body: RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.surfaceContainerLowest,
            onRefresh: () async {
              context.read<DashboardBloc>().add(const LoadDashboardData());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Clickable Search Bar (Navigates to Semantic Search Screen)
                      MultimodalSearchBar(
                        onTap: () {
                          context
                              .read<DashboardBloc>()
                              .add(const ChangeNavigationTab(1));
                        },
                        onVoiceQueryTap: () {
                          context
                              .read<DashboardBloc>()
                              .add(const ChangeNavigationTab(1));
                        },
                      ),
                      const SizedBox(height: 12),

                      // 2. Filter Category Chips
                      FilterChipsRow(
                        selectedCategory: state.selectedFilter,
                        onSelected: (cat) {
                          context
                              .read<DashboardBloc>()
                              .add(ChangeFilterCategory(cat));
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Section Header: My Library & Selection Status
                      _buildLibraryHeader(context, state),
                      const SizedBox(height: 12),

                      // 5. Document List Cards
                      _buildDocumentList(context, state),
                      const SizedBox(height: 16),

                      // 6. Selection Mode Batch Action Bar
                      if (state.hasSelection) ...[
                        BatchActionBar(
                          selectedCount: state.selectedCount,
                          onQueryTap: () {
                            context
                                .read<DashboardBloc>()
                                .add(const ChangeNavigationTab(2));
                          },
                          onExportTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Exporting ${state.selectedCount} document(s)...',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Extra padding for FAB and bottom navbar
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

        // Selection Tag & Filter Button
        Row(
          children: [
            if (state.hasSelection)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '${AppFormatters.formatNumber(state.selectedCount)} SELECTED',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
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
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
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
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return DocumentCard(
          item: item,
          onToggleSelect: () {
            context
                .read<DashboardBloc>()
                .add(ToggleDocumentSelection(item.id));
          },
          onMoreTap: () {
            _showItemOptionsModal(context, item.title);
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
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Vector DB Status'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
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

  void _showItemOptionsModal(BuildContext context, String title) {
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
                  title,
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
                onTap: () => Navigator.pop(ctx),
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
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
