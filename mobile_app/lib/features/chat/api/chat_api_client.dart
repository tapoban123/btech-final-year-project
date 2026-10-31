/// API Client for RAG Chat & Multimodal Assistant operations.
class ChatApiClient {
  final Duration networkDelay;

  ChatApiClient({this.networkDelay = Duration.zero});

  Future<List<Map<String, dynamic>>> getInitialChatHistoryRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return [
      {
        'id': 'msg_1',
        'sender': 'user',
        'content':
            'What are the primary operational risks identified in the Q3 report, and does the voice memo mention mitigation steps?',
        'timestamp': '10:24 AM',
        'points': <Map<String, dynamic>>[],
        'citations': <Map<String, dynamic>>[],
      },
      {
        'id': 'msg_2',
        'sender': 'assistant',
        'content':
            'Based on the combined analysis of the documents and meeting audio:',
        'timestamp': '10:24 AM',
        'points': [
          {
            'number': 1,
            'title': 'Supply Chain Bottlenecks',
            'description':
                'Q3 Report highlights a 14% delay in regional distribution centers across the Midwest corridor.',
            'highlight': '14% delay',
          },
          {
            'number': 2,
            'title': 'Contingency Plan',
            'description':
                'The CEO\'s recorded memo confirms an emergency backup vendor contract is already drafted with renegotiated SLA timelines.',
            'highlight': null,
          },
        ],
        'citations': [
          {
            'title': 'Project_Plan_v7.pdf',
            'reference': 'p.4',
            'type': 'pdf',
          },
          {
            'title': 'Board_Meeting_Memo.wav',
            'reference': '04:12',
            'type': 'audio',
          },
        ],
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getActiveContextsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return [
      {
        'id': 'ctx_1',
        'title': 'Project_Plan_v7.pdf',
        'type': 'pdf',
      },
      {
        'id': 'ctx_2',
        'title': 'Architecture_Diagram.png',
        'type': 'image',
      },
      {
        'id': 'ctx_3',
        'title': 'Board_Meeting_Memo.wav',
        'type': 'audio',
      },
    ];
  }

  Future<Map<String, dynamic>> sendQueryRaw(
    String userPrompt,
    List<String> contextIds,
  ) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    // Return structured RAG response
    return {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'assistant',
      'content':
          'Synthesized query response based on the active multimodal context:',
      'timestamp': 'Just now',
      'points': [
        {
          'number': 1,
          'title': 'Key Finding',
          'description':
              'All highlighted deliverables are synchronized with the active sprint velocity.',
          'highlight': 'active sprint velocity',
        },
      ],
      'citations': [
        {
          'title': 'Project_Plan_v7.pdf',
          'reference': 'p.2',
          'type': 'pdf',
        },
      ],
    };
  }
}
