import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/chat_repository.dart';
import '../repository/models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;

  ChatBloc({IChatRepository? repository})
      : _repository = repository ?? ChatRepository(),
        super(const ChatState()) {
    on<LoadChatData>(_onLoadChatData);
    on<SendChatMessage>(_onSendChatMessage);
    on<SubmitMessageFeedback>(_onSubmitMessageFeedback);
    on<SelectQuickPromptChip>(_onSelectQuickPromptChip);
  }

  Future<void> _onLoadChatData(
    LoadChatData event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await _repository.getChatHistory();
      final contexts = await _repository.getActiveContexts();
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: messages,
        activeContexts: contexts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final queryText = event.text.trim();
    if (queryText.isEmpty) return;

    final userMessage = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      content: queryText,
      timestamp: 'Just now',
    );

    final currentMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(
      messages: currentMessages,
      status: ChatStatus.sending,
    ));

    try {
      final contextIds = state.activeContexts.map((c) => c.id).toList();
      final responseMessage = await _repository.sendQuery(queryText, contextIds);
      final updatedMessages = List<ChatMessage>.from(currentMessages)
        ..add(responseMessage);
      emit(state.copyWith(
        messages: updatedMessages,
        status: ChatStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSubmitMessageFeedback(
    SubmitMessageFeedback event,
    Emitter<ChatState> emit,
  ) {
    final updated = state.messages.map((msg) {
      if (msg.id == event.messageId) {
        return msg.copyWith(isAccurateFeedbackGiven: true);
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updated));
  }

  void _onSelectQuickPromptChip(
    SelectQuickPromptChip event,
    Emitter<ChatState> emit,
  ) {
    add(SendChatMessage(event.prompt));
  }
}
