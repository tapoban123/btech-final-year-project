import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/blocs/chat_bloc.dart';
import '../../../chat/view/screens/chat_screen.dart';
import '../../../search/view/screens/search_screen.dart';
import '../../blocs/dashboard_bloc.dart';
import '../../blocs/dashboard_event.dart';
import '../../blocs/dashboard_state.dart';
import '../widgets/batch_action_bar.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'dashboard_library_view.dart';

/// Main navigation shell Scaffold.
/// Manages tab switching via IndexedStack and hosts the bottom navigation bar
/// (and BatchActionBar when selection mode is enabled).
/// Each nested tab screen manages its own Scaffold, AppBar, and local actions.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: state.currentNavIndex,
            children: [
              // Tab 0: Document Library / Dashboard screen (with its own Scaffold, TopBar, and FAB)
              const DashboardLibraryView(),

              // Tab 1: Semantic Search & Similarity View (with its own Scaffold)
              SearchScreen(
                onNavigateToTab: (idx) {
                  context.read<DashboardBloc>().add(ChangeNavigationTab(idx));
                },
              ),

              // Tab 2: AI Chat & RAG Assistant (with its own Scaffold & ChatHeader)
              Builder(
                builder: (ctx) {
                  try {
                    ctx.read<ChatBloc>();
                    return ChatScreen(
                      showBottomNav: false,
                      showHeader: false,
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
          bottomNavigationBar: state.isSelectionMode
              ? BatchActionBar(
                  selectedCount: state.selectedCount,
                  onChatTap: () {
                    context
                        .read<DashboardBloc>()
                        .add(const ChangeNavigationTab(2));
                  },
                  onShareTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sharing ${state.selectedCount} file(s)...',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onDeleteTap: () {
                    _confirmBatchDelete(context, state.selectedCount);
                  },
                  onCloseTap: () {
                    context
                        .read<DashboardBloc>()
                        .add(const ToggleSelectionMode(false));
                  },
                )
              : DashboardBottomNav(
                  currentIndex: state.currentNavIndex,
                  onTabSelected: (index) {
                    context
                        .read<DashboardBloc>()
                        .add(ChangeNavigationTab(index));
                  },
                ),
        );
      },
    );
  }

  void _confirmBatchDelete(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Files'),
        content: Text(
          'Are you sure you want to delete $count selected file(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DashboardBloc>().add(const DeleteSelectedDocuments());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted $count file(s)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
