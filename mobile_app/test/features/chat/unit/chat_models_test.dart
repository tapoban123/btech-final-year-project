import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/chat/models/chat_history_model.dart';
import 'package:mobile_app/features/chat/models/chat_query_model.dart';

void main() {
  group('DocumentQueryRequestModel Unit Tests', () {
    test('serializes to JSON correctly', () {
      const request = DocumentQueryRequestModel(query: 'Summarize meeting');
      expect(request.toJson(), {'query': 'Summarize meeting'});
    });

    test('deserializes from JSON correctly', () {
      final model =
          DocumentQueryRequestModel.fromJson({'query': 'Find key takeaways'});
      expect(model.query, 'Find key takeaways');
    });
  });

  group('QueryCitationModel Unit Tests', () {
    test('deserializes from backend citation JSON', () {
      final json = {
        'document_id': 'doc_cite_1',
        'document_name': 'Meeting_Notes.pdf',
        'page': 3,
        'snippet': 'Action items discussed during meeting.',
        'cloudinary_url': 'https://cloudinary.com/notes.pdf',
        'mime_type': 'application/pdf',
      };

      final citation = QueryCitationModel.fromJson(json);

      expect(citation.documentId, 'doc_cite_1');
      expect(citation.documentName, 'Meeting_Notes.pdf');
      expect(citation.page, 3);
      expect(citation.snippet, 'Action items discussed during meeting.');
      expect(citation.cloudinaryUrl, 'https://cloudinary.com/notes.pdf');
      expect(citation.mimeType, 'application/pdf');
    });

    test('toJson produces correct snake_case keys', () {
      const citation = QueryCitationModel(
        documentId: 'doc_1',
        documentName: 'Contract.pdf',
        page: 1,
      );

      final json = citation.toJson();
      expect(json['document_id'], 'doc_1');
      expect(json['document_name'], 'Contract.pdf');
      expect(json['page'], 1);
    });
  });

  group('MultiDocumentQueryResponseModel Unit Tests', () {
    test('deserializes full response with citations and matched documents', () {
      final json = {
        'answer': 'The quarterly revenue increased by 15%.',
        'sources': [
          {
            'document_id': 'doc_1',
            'document_name': 'Q3.pdf',
            'page': 2,
            'snippet': 'Revenue up 15%.',
          },
        ],
        'documents': [
          {
            'document_id': 'doc_1',
            'filename': 'Q3.pdf',
            'size_bytes': 1024,
            'status': 'completed',
          },
        ],
      };

      final response = MultiDocumentQueryResponseModel.fromJson(json);

      expect(response.answer, 'The quarterly revenue increased by 15%.');
      expect(response.sources.length, 1);
      expect(response.sources.first.documentName, 'Q3.pdf');
      expect(response.documents.length, 1);
      expect(response.documents.first.filename, 'Q3.pdf');
    });

    test('handles empty sources and documents gracefully', () {
      final response = MultiDocumentQueryResponseModel.fromJson({
        'answer': 'No context found.',
        'sources': [],
        'documents': [],
      });

      expect(response.answer, 'No context found.');
      expect(response.sources, isEmpty);
      expect(response.documents, isEmpty);
    });
  });

  group('ChatHistoryItemModel Unit Tests', () {
    test('deserializes history items with points and citations', () {
      final json = {
        'id': 'msg_101',
        'sender': 'assistant',
        'content': 'Key synthesis points:',
        'timestamp': '11:00 AM',
        'points': [
          {
            'number': 1,
            'title': 'Milestone Achieved',
            'description': 'Deliverable completed on schedule.',
            'highlight': 'on schedule',
          },
        ],
        'citations': [
          {
            'title': 'Sprint.pdf',
            'reference': 'p.4',
            'type': 'pdf',
          },
        ],
      };

      final item = ChatHistoryItemModel.fromJson(json);

      expect(item.id, 'msg_101');
      expect(item.sender, 'assistant');
      expect(item.points.length, 1);
      expect(item.points.first.title, 'Milestone Achieved');
      expect(item.points.first.highlight, 'on schedule');
      expect(item.citations.length, 1);
      expect(item.citations.first.reference, 'p.4');
    });
  });

  group('ActiveRAGContextModel Unit Tests', () {
    test('serializes and deserializes accurately', () {
      const model = ActiveRAGContextModel(
        id: 'ctx_9',
        title: 'Strategy.png',
        type: 'image',
      );

      final json = model.toJson();
      final fromJson = ActiveRAGContextModel.fromJson(json);

      expect(fromJson.id, 'ctx_9');
      expect(fromJson.title, 'Strategy.png');
      expect(fromJson.type, 'image');
    });
  });
}
