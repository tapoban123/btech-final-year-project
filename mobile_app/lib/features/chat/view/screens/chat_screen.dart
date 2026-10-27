import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/view/widgets/dashboard_bottom_nav.dart';
import '../../blocs/chat_bloc.dart';
import '../../blocs/chat_event.dart';
import '../../blocs/chat_state.dart';
import '../../repository/models/chat_message.dart';
import '../widgets/assistant_message_bubble.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/prompt_chips_row.dart';
import '../widgets/rag_context_strip.dart';
import '../widgets/user_message_bubble.dart';
import '../../../../core/utils/app_formatters.dart';

class ChatScreen extends StatefulWidget {
  final bool showBottomNav;
  final VoidCallback? onBackTap;
  final bool showHeader;

  const ChatScreen({
    super.key,
    this.showBottomNav = true,
    this.onBackTap,
    this.showHeader = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadChatData());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.status == ChatStatus.success ||
            state.status == ChatStatus.sending) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          appBar: widget.showHeader
              ? ChatHeader(
                  onBackTap: () {
                    if (widget.onBackTap != null) {
                      widget.onBackTap!();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  onManageTap: () => _showManageContextSheet(context, state),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Active RAG Context Strip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: RAGContextStrip(
                    activeContexts: state.activeContexts,
                    isGrounded: state.isGrounded,
                    onContextTap: () => _showManageContextSheet(context, state),
                  ),
                ),

                // 2. Chat Feed Area
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ListView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        children: [
                          // Timestamp divider
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                AppFormatters.formatHeaderTimestamp(
                                  dateTime: DateTime(2026, 1, 1, 10, 24),
                                ),
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.outline,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Message Bubbles
                          for (final message in state.messages) ...[
                            if (message.sender == MessageSender.user)
                              UserMessageBubble(message: message)
                            else
                              AssistantMessageBubble(
                                message: message,
                                onAccurateTap: () {
                                  context.read<ChatBloc>().add(
                                        SubmitMessageFeedback(
                                          messageId: message.id,
                                          isAccurate: true,
                                        ),
                                      );
                                },
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Bottom Interactive Control Deck
                Container(
                  color: AppColors.surfaceContainerLowest,
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quick-Action Prompt Chips
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: PromptChipsRow(
                              prompts: state.quickPromptChips,
                              onPromptTap: (prompt) {
                                context
                                    .read<ChatBloc>()
                                    .add(SelectQuickPromptChip(prompt));
                              },
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Input Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: ChatInputBar(
                              controller: _inputController,
                              isSending: state.status == ChatStatus.sending,
                              onSend: (text) {
                                context
                                    .read<ChatBloc>()
                                    .add(SendChatMessage(text));
                              },
                              onVoiceRecordTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Multimodal Voice Dictation Active (Listening...)',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: widget.showBottomNav
              ? DashboardBottomNav(
                  currentIndex: 2, // Chat Tab Active
                  onTabSelected: (index) {
                    if (widget.onBackTap != null && index == 0) {
                      widget.onBackTap!();
                    } else if (index == 0) {
                      // Navigate back to Home/Dashboard
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    } else if (index == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semantic Search & Similarity'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                )
              : null,
        );
      },
    );
  }

  void _showManageContextSheet(BuildContext context, ChatState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active RAG Contexts (${state.activeContexts.length})',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              for (final c in state.activeContexts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  title: Text(
                    c.title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    'Active',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Done',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
