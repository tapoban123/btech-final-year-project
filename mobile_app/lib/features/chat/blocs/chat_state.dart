import 'package:equatable/equatable.dart';
import '../repository/models/chat_message.dart';

enum ChatStatus { initial, loading, success, sending, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<ActiveRAGContext> activeContexts;
  final bool isGrounded;
  final List<String> quickPromptChips;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.activeContexts = const [],
    this.isGrounded = true,
    this.quickPromptChips = const [
      'Summarize these docs',
      'Extract key action items',
      'Compare these reports',
    ],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<ActiveRAGContext>? activeContexts,
    bool? isGrounded,
    List<String>? quickPromptChips,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      activeContexts: activeContexts ?? this.activeContexts,
      isGrounded: isGrounded ?? this.isGrounded,
      quickPromptChips: quickPromptChips ?? this.quickPromptChips,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        activeContexts,
        isGrounded,
        quickPromptChips,
        errorMessage,
      ];
}
