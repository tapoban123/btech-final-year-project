import '../../dashboard/repository/models/document_item.dart';
import '../api/chat_api_client.dart';
import '../models/chat_history_model.dart';
import '../models/chat_query_model.dart';
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
    final List<ChatHistoryItemModel> list =
        await _apiClient.getInitialChatHistory();
    return list.map((item) {
      final sender = item.sender == 'assistant'
          ? MessageSender.assistant
          : MessageSender.user;

      final points = item.points.map((p) {
        return SynthesisPoint(
          number: p.number,
          title: p.title,
          description: p.description,
          highlight: p.highlight,
        );
      }).toList();

      final citations = item.citations.map((c) {
        return CitationItem(
          title: c.title,
          reference: c.reference,
          type: _inferDocType(c.type),
        );
      }).toList();

      return ChatMessage(
        id: item.id,
        sender: sender,
        content: item.content,
        timestamp: item.timestamp,
        synthesisPoints: points,
        citations: citations,
      );
    }).toList();
  }

  @override
  Future<List<ActiveRAGContext>> getActiveContexts() async {
    final list = await _apiClient.getActiveContexts();
    return list.map((c) {
      return ActiveRAGContext(
        id: c.id,
        title: c.title,
        type: _inferDocType(c.type),
      );
    }).toList();
  }

  @override
  Future<ChatMessage> sendQuery(
    String userPrompt,
    List<String> contextIds,
  ) async {
    final request = DocumentQueryRequestModel(query: userPrompt);
    final response = await _apiClient.sendQuery(request);

    final citations = response.sources.map((s) {
      return CitationItem(
        title: s.documentName.isNotEmpty ? s.documentName : 'Document',
        reference: 'p.${s.page}',
        type: _inferDocType(s.mimeType ?? 'pdf'),
      );
    }).toList();

    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      content: response.answer,
      timestamp: 'Just now',
      synthesisPoints: [
        SynthesisPoint(
          number: 1,
          title: 'Key Finding',
          description: response.answer,
        ),
      ],
      citations: citations,
    );
  }

  DocumentType _inferDocType(String typeStr) {
    final lower = typeStr.toLowerCase();
    if (lower == 'image' || lower.startsWith('image/')) {
      return DocumentType.image;
    }
    if (lower == 'audio' || lower.startsWith('audio/')) {
      return DocumentType.audio;
    }
    if (lower == 'docx' || lower.endsWith('.docx')) {
      return DocumentType.docx;
    }
    return DocumentType.pdf;
  }
}
