import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/chat/blocs/chat_bloc.dart';
import 'package:mobile_app/features/chat/blocs/chat_event.dart';
import 'package:mobile_app/features/chat/blocs/chat_state.dart';
import 'package:mobile_app/features/chat/repository/chat_repository.dart';
import 'package:mobile_app/features/chat/repository/models/chat_message.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockChatRepository mockRepository;

  final initialMessages = [
    const ChatMessage(
      id: 'msg_1',
      sender: MessageSender.user,
      content: 'Analyze report',
      timestamp: '10:00 AM',
    ),
  ];

  final activeContexts = [
    const ActiveRAGContext(
      id: 'ctx_1',
      title: 'Doc.pdf',
      type: DocumentType.pdf,
    ),
  ];

  setUp(() {
    mockRepository = MockChatRepository();
  });

  group('ChatBloc Tests', () {
    test('initial state has default configuration', () {
      final bloc = ChatBloc(repository: mockRepository);
      expect(bloc.state.status, ChatStatus.initial);
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isGrounded, isTrue);
      expect(bloc.state.quickPromptChips.length, 3);
    });

    blocTest<ChatBloc, ChatState>(
      'emits [loading, success] when LoadChatData succeeds',
      build: () {
        when(() => mockRepository.getChatHistory())
            .thenAnswer((_) async => initialMessages);
        when(() => mockRepository.getActiveContexts())
            .thenAnswer((_) async => activeContexts);
        return ChatBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadChatData()),
      expect: () => [
        const ChatState(status: ChatStatus.loading),
        ChatState(
          status: ChatStatus.success,
          messages: initialMessages,
          activeContexts: activeContexts,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [loading, failure] when LoadChatData fails',
      build: () {
        when(() => mockRepository.getChatHistory())
            .thenThrow(Exception('Failed to load chat history'));
        return ChatBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadChatData()),
      expect: () => [
        const ChatState(status: ChatStatus.loading),
        predicate<ChatState>((state) {
          return state.status == ChatStatus.failure &&
              state.errorMessage != null;
        }),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [sending, success] with user and assistant messages on SendChatMessage',
      build: () {
        when(() => mockRepository.sendQuery(any(), any())).thenAnswer(
          (_) async => const ChatMessage(
            id: 'res_assistant',
            sender: MessageSender.assistant,
            content: 'Here is the summary',
            timestamp: 'Just now',
          ),
        );
        return ChatBloc(repository: mockRepository);
      },
      seed: () => ChatState(
        messages: initialMessages,
        activeContexts: activeContexts,
      ),
      act: (bloc) => bloc.add(const SendChatMessage('Give summary')),
      expect: () => [
        predicate<ChatState>((state) {
          return state.status == ChatStatus.sending &&
              state.messages.length == 2 &&
              state.messages.last.content == 'Give summary' &&
              state.messages.last.sender == MessageSender.user;
        }),
        predicate<ChatState>((state) {
          return state.status == ChatStatus.success &&
              state.messages.length == 3 &&
              state.messages.last.content == 'Here is the summary' &&
              state.messages.last.sender == MessageSender.assistant;
        }),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ignores empty and whitespace-only prompt strings',
      build: () => ChatBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const SendChatMessage('   ')),
      expect: () => [],
    );

    blocTest<ChatBloc, ChatState>(
      'updates message feedback to accurate when SubmitMessageFeedback event received',
      build: () => ChatBloc(repository: mockRepository),
      seed: () => ChatState(messages: initialMessages),
      act: (bloc) => bloc.add(
        const SubmitMessageFeedback(messageId: 'msg_1', isAccurate: true),
      ),
      expect: () => [
        ChatState(
          messages: [
            initialMessages.first.copyWith(isAccurateFeedbackGiven: true),
          ],
        ),
      ],
    );
  });
}
