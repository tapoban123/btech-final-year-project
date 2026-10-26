import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/chat/repository/models/chat_message.dart';
import 'package:mobile_app/features/chat/view/widgets/assistant_message_bubble.dart';
import 'package:mobile_app/features/chat/view/widgets/chat_header.dart';
import 'package:mobile_app/features/chat/view/widgets/chat_input_bar.dart';
import 'package:mobile_app/features/chat/view/widgets/grounding_citation_card.dart';
import 'package:mobile_app/features/chat/view/widgets/prompt_chips_row.dart';
import 'package:mobile_app/features/chat/view/widgets/rag_context_strip.dart';
import 'package:mobile_app/features/chat/view/widgets/user_message_bubble.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

void main() {
  group('Chat Component Widget Tests', () {
    testWidgets('ChatHeader renders back button and title and triggers callbacks',
        (tester) async {
      bool backTapped = false;
      bool manageTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: ChatHeader(
              onBackTap: () => backTapped = true,
              onManageTap: () => manageTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('OmniDoc'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backTapped, isTrue);

      await tester.tap(find.text('Manage'));
      expect(manageTapped, isTrue);
    });

    testWidgets('RAGContextStrip renders active context count and grounded pill',
        (tester) async {
      const contexts = [
        ActiveRAGContext(id: '1', title: 'File1.pdf', type: DocumentType.pdf),
        ActiveRAGContext(id: '2', title: 'Audio.wav', type: DocumentType.audio),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RAGContextStrip(
              activeContexts: contexts,
              isGrounded: true,
            ),
          ),
        ),
      );

      expect(find.text('2 Active Contexts'), findsOneWidget);
      expect(find.text('Grounded'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('UserMessageBubble renders message content and delivery receipt',
        (tester) async {
      const msg = ChatMessage(
        id: '1',
        sender: MessageSender.user,
        content: 'What is the projected ROI?',
        timestamp: '11:05 AM',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserMessageBubble(message: msg),
          ),
        ),
      );

      expect(find.text('What is the projected ROI?'), findsOneWidget);
      expect(find.text('11:05 AM'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('AssistantMessageBubble renders points and feedback options',
        (tester) async {
      bool feedbackTapped = false;

      const assistantMsg = ChatMessage(
        id: 'a1',
        sender: MessageSender.assistant,
        content: 'Analysis output:',
        timestamp: '11:06 AM',
        synthesisPoints: [
          SynthesisPoint(
            number: 1,
            title: 'ROI Forecast',
            description: 'Expected 24% return over 12 months',
            highlight: '24% return',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssistantMessageBubble(
              message: assistantMsg,
              onAccurateTap: () => feedbackTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('OmniDoc AI'), findsOneWidget);
      expect(find.text('Analysis output:'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Accurate'), findsOneWidget);
      expect(find.text('Export memo'), findsOneWidget);

      await tester.tap(find.text('Accurate'));
      expect(feedbackTapped, isTrue);
    });

    testWidgets('GroundingCitationCard renders citation badge and title',
        (tester) async {
      const citations = [
        CitationItem(
          title: 'Financial_Model.pdf',
          reference: 'p.8',
          type: DocumentType.pdf,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroundingCitationCard(citations: citations),
          ),
        ),
      );

      expect(find.text('GROUNDING EVIDENCE'), findsOneWidget);
      expect(find.text('Financial_Model.pdf'), findsOneWidget);
      expect(find.text('(p.8)'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });

    testWidgets('PromptChipsRow renders chips and triggers callback',
        (tester) async {
      String selectedPrompt = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptChipsRow(
              prompts: const ['Summarize these docs', 'Key findings'],
              onPromptTap: (p) => selectedPrompt = p,
            ),
          ),
        ),
      );

      expect(find.text('Summarize these docs'), findsOneWidget);
      expect(find.text('Key findings'), findsOneWidget);

      await tester.tap(find.text('Summarize these docs'));
      expect(selectedPrompt, 'Summarize these docs');
    });

    testWidgets('ChatInputBar enters text and sends on arrow button tap',
        (tester) async {
      final controller = TextEditingController();
      String sentMessage = '';
      bool micPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputBar(
              controller: controller,
              onSend: (val) => sentMessage = val,
              onVoiceRecordTap: () => micPressed = true,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'Give a breakdown of the budget',
      );
      await tester.tap(find.byIcon(Icons.arrow_upward));

      expect(sentMessage, 'Give a breakdown of the budget');
      expect(controller.text, isEmpty);

      await tester.tap(find.byIcon(Icons.mic));
      expect(micPressed, isTrue);
    });
  });
}
