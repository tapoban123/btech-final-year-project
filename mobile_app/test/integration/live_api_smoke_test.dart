import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/chat/api/chat_api_client.dart';
import 'package:mobile_app/features/chat/models/chat_query_model.dart';
import 'package:mobile_app/features/dashboard/api/document_api_client.dart';
import 'package:mobile_app/features/dashboard/models/document_search_model.dart';

void main() {
  setUpAll(() {
    // Unset flutter_test http overrides to allow real socket/HTTP network calls to the live server
    HttpOverrides.global = null;
  });

  group('Live Remote Backend Integration & Parsing Verification', () {
    test('1. Reachability & Document Library: GET /api/v1/documents', () async {
      final apiClient = DocumentApiClient();
      final response = await apiClient.getDocuments();

      expect(response.documents, isNotEmpty);
      final firstDoc = response.documents.first;
      expect(firstDoc.resolvedId, isNotEmpty);
      expect(firstDoc.filename, isNotEmpty);
      expect(firstDoc.sizeBytes, greaterThan(0));
      expect(firstDoc.status, isNotEmpty);
    });

    test('2. Semantic Search Endpoint: POST /api/v1/documents/search', () async {
      final apiClient = DocumentApiClient();
      final response = await apiClient.searchDocuments(
        const DocumentSearchRequestModel(query: 'machine learning biology'),
      );

      expect(response.query, 'machine learning biology');
      expect(response.documents, isA<List<DocumentSearchResultModel>>());
    });

    test('3. RAG Query Endpoint: POST /api/v1/documents/query', () async {
      final chatClient = ChatApiClient();
      final response = await chatClient.sendQuery(
        const DocumentQueryRequestModel(query: 'Summarize the documents available'),
      );

      expect(response.answer, isNotEmpty);
      expect(response.sources, isA<List<QueryCitationModel>>());
    });
  });
}
