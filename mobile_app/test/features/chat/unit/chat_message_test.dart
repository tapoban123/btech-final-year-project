import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/chat/repository/models/chat_message.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

void main() {
  group('ChatMessage Models Unit Tests', () {
    test('CitationItem equality and props', () {
      const c1 = CitationItem(
        title: 'File.pdf',
        reference: 'p.4',
        type: DocumentType.pdf,
      );
      const c2 = CitationItem(
        title: 'File.pdf',
        reference: 'p.4',
        type: DocumentType.pdf,
      );

      expect(c1, equals(c2));
      expect(c1.props, ['File.pdf', 'p.4', DocumentType.pdf]);
    });

    test('SynthesisPoint equality and props', () {
      const p1 = SynthesisPoint(
        number: 1,
        title: 'Risk',
        description: 'High risk factor',
        highlight: 'High risk',
      );
      const p2 = SynthesisPoint(
        number: 1,
        title: 'Risk',
        description: 'High risk factor',
        highlight: 'High risk',
      );

      expect(p1, equals(p2));
      expect(p1.props, [1, 'Risk', 'High risk factor', 'High risk']);
    });

    test('ChatMessage copyWith preserves and modifies fields', () {
      const original = ChatMessage(
        id: 'msg_1',
        sender: MessageSender.user,
        content: 'Hello',
        timestamp: '10:00 AM',
        isAccurateFeedbackGiven: false,
      );

      final updated = original.copyWith(
        content: 'Updated content',
        isAccurateFeedbackGiven: true,
      );

      expect(updated.id, 'msg_1');
      expect(updated.content, 'Updated content');
      expect(updated.isAccurateFeedbackGiven, isTrue);
      expect(updated.sender, MessageSender.user);
    });

    test('ActiveRAGContext equality and props', () {
      const ctx1 = ActiveRAGContext(
        id: '1',
        title: 'Doc.pdf',
        type: DocumentType.pdf,
      );
      const ctx2 = ActiveRAGContext(
        id: '1',
        title: 'Doc.pdf',
        type: DocumentType.pdf,
      );

      expect(ctx1, equals(ctx2));
      expect(ctx1.props, ['1', 'Doc.pdf', DocumentType.pdf]);
    });
  });
}
