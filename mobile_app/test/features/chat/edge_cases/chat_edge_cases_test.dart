import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/chat/blocs/chat_bloc.dart';
import 'package:mobile_app/features/chat/repository/chat_repository.dart';
import 'package:mobile_app/features/chat/repository/models/chat_message.dart';
import 'package:mobile_app/features/chat/view/screens/chat_screen.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockChatRepository mockRepository;

  final sampleContexts = [
    const ActiveRAGContext(
      id: 'ctx_1',
      title: 'Audit_Report.pdf',
      type: DocumentType.pdf,
    ),
    const ActiveRAGContext(
      id: 'ctx_2',
      title: 'Meeting_Audio.wav',
      type: DocumentType.audio,
    ),
  ];

  setUp(() {
    mockRepository = MockChatRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<IChatRepository>.value(
      value: mockRepository,
      child: BlocProvider<ChatBloc>(
        create: (_) => ChatBloc(repository: mockRepository),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChatScreen(),
        ),
      ),
    );
  }

  group('Chat Edge Cases Tests', () {
    testWidgets('handles empty initial chat history gracefully',
        (tester) async {
      when(() => mockRepository.getChatHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getActiveContexts())
          .thenAnswer((_) async => sampleContexts);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('2 Active Contexts'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('Ask questions about the selection...'), findsOneWidget);
    });

    testWidgets('opening and closing Manage Contexts bottom sheet',
        (tester) async {
      when(() => mockRepository.getChatHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getActiveContexts())
          .thenAnswer((_) async => sampleContexts);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open manage sheet
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(find.text('Active RAG Contexts (2)'), findsOneWidget);
      expect(find.text('Audit_Report.pdf'), findsOneWidget);
      expect(find.text('Meeting_Audio.wav'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Active RAG Contexts (2)'), findsNothing);
    });

    testWidgets('tapping quick prompt chip sends message to AI assistant',
        (tester) async {
      when(() => mockRepository.getChatHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getActiveContexts())
          .thenAnswer((_) async => sampleContexts);
      when(() => mockRepository.sendQuery(any(), any())).thenAnswer(
        (_) async => const ChatMessage(
          id: 'ai_resp',
          sender: MessageSender.assistant,
          content: 'Here is the executive summary',
          timestamp: 'Just now',
          synthesisPoints: [
            SynthesisPoint(
              number: 1,
              title: 'Executive Summary',
              description: 'Key deliverables are completed.',
            ),
          ],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap prompt chip
      await tester.tap(find.text('Summarize these docs'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('Executive Summary'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty input submission is ignored', (tester) async {
      when(() => mockRepository.getChatHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getActiveContexts())
          .thenAnswer((_) async => sampleContexts);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap send with empty input
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepository.sendQuery(any(), any()));
    });
  });
}
