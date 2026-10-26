import '../../dashboard/repository/models/document_item.dart';
import '../api/chat_api_client.dart';
import 'models/chat_message.dart';

abstract class IChatRepository {
  Future<List<ChatMessage>> getChatHistory();
  Future<List<ActiveRAGContext>> getActiveContexts();
  Future<ChatMessage> sendQuery(String userPrompt, List<String> contextIds);
}

class ChatRepository implements IChatRepository {
  final ChatApiClient _apiClient;

  ChatRepository({ChatApiClient? apiClient})
      : _apiClient = apiClient ?? ChatApiClient();

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    final rawList = await _apiClient.getInitialChatHistoryRaw();
    return rawList.map((item) {
      final senderStr = item['sender'] as String? ?? 'user';
      final sender = senderStr == 'assistant'
          ? MessageSender.assistant
          : MessageSender.user;

      final rawPoints = (item['points'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final points = rawPoints.map((p) {
        return SynthesisPoint(
          number: p['number'] as int? ?? 1,
          title: p['title'] as String? ?? '',
          description: p['description'] as String? ?? '',
          highlight: p['highlight'] as String?,
        );
      }).toList();

      final rawCitations =
          (item['citations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final citations = rawCitations.map((c) {
        final typeStr = c['type'] as String? ?? 'pdf';
        final DocumentType docType;
        switch (typeStr) {
          case 'image':
            docType = DocumentType.image;
            break;
          case 'audio':
            docType = DocumentType.audio;
            break;
          case 'docx':
            docType = DocumentType.docx;
            break;
          case 'pdf':
          default:
            docType = DocumentType.pdf;
            break;
        }

        return CitationItem(
          title: c['title'] as String? ?? '',
          reference: c['reference'] as String? ?? '',
          type: docType,
        );
      }).toList();

      return ChatMessage(
        id: item['id'] as String,
        sender: sender,
        content: item['content'] as String,
        timestamp: item['timestamp'] as String,
        synthesisPoints: points,
        citations: citations,
      );
    }).toList();
  }

  @override
  Future<List<ActiveRAGContext>> getActiveContexts() async {
    final rawList = await _apiClient.getActiveContextsRaw();
    return rawList.map((c) {
      final typeStr = c['type'] as String? ?? 'pdf';
      final DocumentType docType;
      switch (typeStr) {
        case 'image':
          docType = DocumentType.image;
          break;
        case 'audio':
          docType = DocumentType.audio;
          break;
        case 'docx':
          docType = DocumentType.docx;
          break;
        case 'pdf':
        default:
          docType = DocumentType.pdf;
          break;
      }

      return ActiveRAGContext(
        id: c['id'] as String,
        title: c['title'] as String,
        type: docType,
      );
    }).toList();
  }

  @override
  Future<ChatMessage> sendQuery(
    String userPrompt,
    List<String> contextIds,
  ) async {
    final raw = await _apiClient.sendQueryRaw(userPrompt, contextIds);
    final rawPoints = (raw['points'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final points = rawPoints.map((p) {
      return SynthesisPoint(
        number: p['number'] as int? ?? 1,
        title: p['title'] as String? ?? '',
        description: p['description'] as String? ?? '',
        highlight: p['highlight'] as String?,
      );
    }).toList();

    final rawCitations =
        (raw['citations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final citations = rawCitations.map((c) {
      return CitationItem(
        title: c['title'] as String? ?? '',
        reference: c['reference'] as String? ?? '',
        type: DocumentType.pdf,
      );
    }).toList();

    return ChatMessage(
      id: raw['id'] as String,
      sender: MessageSender.assistant,
      content: raw['content'] as String,
      timestamp: raw['timestamp'] as String,
      synthesisPoints: points,
      citations: citations,
    );
  }
}
