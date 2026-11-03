import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/chat/api/chat_api_client.dart';
import 'package:mobile_app/features/chat/repository/chat_repository.dart';
import 'package:mobile_app/features/chat/repository/models/chat_message.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';

class MockChatApiClient extends Mock implements ChatApiClient {}

void main() {
  late MockChatApiClient mockApiClient;
  late ChatRepository repository;

  setUp(() {
    mockApiClient = MockChatApiClient();
    repository = ChatRepository(apiClient: mockApiClient);
  });

  group('ChatRepository with Mock Responses', () {
    test('getChatHistory maps raw messages to List<ChatMessage>', () async {
      when(() => mockApiClient.getInitialChatHistoryRaw()).thenAnswer(
        (_) async => [
          {
            'id': 'm1',
            'sender': 'user',
            'content': 'How is Q3?',
            'timestamp': '10:00 AM',
            'points': <Map<String, dynamic>>[],
            'citations': <Map<String, dynamic>>[],
          },
          {
            'id': 'm2',
            'sender': 'assistant',
            'content': 'Q3 went well.',
            'timestamp': '10:01 AM',
            'points': [
              {
                'number': 1,
                'title': 'Growth',
                'description': 'Revenue up 20%',
                'highlight': '20%',
              },
            ],
            'citations': [
              {
                'title': 'Report.pdf',
                'reference': 'p.1',
                'type': 'pdf',
              },
            ],
          },
        ],
      );

      final messages = await repository.getChatHistory();

      expect(messages.length, 2);
      expect(messages[0].sender, MessageSender.user);
      expect(messages[1].sender, MessageSender.assistant);
      expect(messages[1].synthesisPoints.first.title, 'Growth');
      expect(messages[1].citations.first.reference, 'p.1');
      expect(messages[1].citations.first.type, DocumentType.pdf);
    });

    test('getActiveContexts maps raw contexts accurately', () async {
      when(() => mockApiClient.getActiveContextsRaw()).thenAnswer(
        (_) async => [
          {
            'id': 'c1',
            'title': 'Voice.wav',
            'type': 'audio',
          },
        ],
      );

      final contexts = await repository.getActiveContexts();

      expect(contexts.length, 1);
      expect(contexts.first.id, 'c1');
      expect(contexts.first.type, DocumentType.audio);
    });

    test('sendQuery sends prompt and returns assistant response', () async {
      when(() => mockApiClient.sendQueryRaw('Explain risk', ['ctx_1']))
          .thenAnswer(
        (_) async => {
          'id': 'res_1',
          'sender': 'assistant',
          'content': 'Here is the risk breakdown',
          'timestamp': 'Just now',
          'points': [
            {
              'number': 1,
              'title': 'Risk Item',
              'description': 'Description of risk',
            },
          ],
          'citations': [
            {
              'title': 'Audit.pdf',
              'reference': 'p.10',
            },
          ],
        },
      );

      final response = await repository.sendQuery('Explain risk', ['ctx_1']);

      expect(response.id, 'res_1');
      expect(response.sender, MessageSender.assistant);
      expect(response.synthesisPoints.length, 1);
      expect(response.citations.length, 1);
    });

    test('propagates exception when API client fails', () async {
      when(() => mockApiClient.getInitialChatHistoryRaw())
          .thenThrow(Exception('Backend service unavailable (503)'));

      expect(() => repository.getChatHistory(), throwsA(isA<Exception>()));
    });
  });
}
