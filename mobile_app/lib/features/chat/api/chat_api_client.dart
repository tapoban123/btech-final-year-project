import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/chat_history_model.dart';
import '../models/chat_query_model.dart';

/// API Client for RAG Chat & Multimodal Assistant operations using global DioClient.
class ChatApiClient {
  final Dio _dio;
  final Duration networkDelay;

  ChatApiClient({
    Dio? dio,
    this.networkDelay = Duration.zero,
  }) : _dio = dio ?? DioClient().dio;

  Dio get client => _dio;

  Future<List<ChatHistoryItemModel>> getInitialChatHistory() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return _defaultInitialHistory;
  }

  Future<List<ActiveRAGContextModel>> getActiveContexts() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return _defaultActiveContexts;
  }

  Future<MultiDocumentQueryResponseModel> sendQuery(
    DocumentQueryRequestModel request,
  ) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    try {
      final response = await _dio.post(
        ApiConstants.queryDocuments,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return MultiDocumentQueryResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Basic single-level fallback for offline / test environments
      return _defaultQueryResponse(request.query);
    }

    return _defaultQueryResponse(request.query);
  }

  static MultiDocumentQueryResponseModel _defaultQueryResponse(String prompt) =>
      const MultiDocumentQueryResponseModel(
        answer:
            'Synthesized query response based on the active multimodal context:',
        sources: [
          QueryCitationModel(
            documentId: 'doc_1',
            documentName: 'Q3_Financial_Analysis_Report.pdf',
            page: 14,
            snippet:
                'Q3 operational expense breakdown shows significant capital efficiency.',
          ),
          QueryCitationModel(
            documentId: 'doc_2',
            documentName: 'Executive_Strategy_Whiteboard.png',
            page: 1,
            snippet:
                'System architecture nodes cross-referenced with enterprise SLA goals.',
          ),
        ],
      );

  static const List<ChatHistoryItemModel> _defaultInitialHistory = [
    ChatHistoryItemModel(
      id: 'msg_1',
      sender: 'user',
      content:
          'Can you cross-reference our Q3 marketing expenses against the product launch timeline from the meeting memo?',
      timestamp: '10:42 AM',
    ),
    ChatHistoryItemModel(
      id: 'msg_2',
      sender: 'assistant',
      content:
          'Based on the synthesized analysis across your documents, here are the key findings:',
      timestamp: '10:43 AM',
      points: [
        SynthesisPointModel(
          number: 1,
          title: 'Direct Alignment with Milestone 2',
          description:
              'Marketing budget allocation of \$420k directly aligns with the Phase II Product Launch described in the meeting memo.',
          highlight: '\$420k',
        ),
        SynthesisPointModel(
          number: 2,
          title: 'Digital Ad Variance',
          description:
              'Digital ad spending peaked 2 weeks prior to hardware certification, as documented in the whiteboard notes.',
        ),
      ],
      citations: [
        ChatCitationModel(
          title: 'Q3_Financial_Analysis_Report.pdf',
          reference: 'p.14',
          type: 'pdf',
        ),
        ChatCitationModel(
          title: 'Board_Meeting_Memo_Dictation.wav',
          reference: '14:22',
          type: 'audio',
        ),
      ],
    ),
  ];

  static const List<ActiveRAGContextModel> _defaultActiveContexts = [
    ActiveRAGContextModel(
      id: 'ctx_1',
      title: 'Q3_Financial_Analysis_Report.pdf',
      type: 'pdf',
    ),
    ActiveRAGContextModel(
      id: 'ctx_2',
      title: 'Board_Meeting_Memo_Dictation.wav',
      type: 'audio',
    ),
    ActiveRAGContextModel(
      id: 'ctx_3',
      title: 'Executive_Strategy_Whiteboard.png',
      type: 'image',
    ),
  ];
}
