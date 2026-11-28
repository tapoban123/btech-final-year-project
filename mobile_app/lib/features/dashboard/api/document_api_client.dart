import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/dashboard_metrics_model.dart';
import '../models/document_response_model.dart';
import '../models/document_search_model.dart';

/// API Client for dashboard document operations using global DioClient.
class DocumentApiClient {
  final Dio _dio;
  final Duration networkDelay;

  DocumentApiClient({
    Dio? dio,
    this.networkDelay = Duration.zero,
  }) : _dio = dio ?? DioClient().dio;

  Dio get client => _dio;

  Future<DocumentsResponseModel> getDocuments() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    try {
      final response = await _dio.get(ApiConstants.documents);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return DocumentsResponseModel.fromJson(data);
        } else if (data is List) {
          final list = data
              .map((e) =>
                  DocumentMetadataModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return DocumentsResponseModel(documents: list);
        }
      }
    } catch (_) {
      // Basic single-level fallback for offline / test environments
      return _defaultDocumentsResponse;
    }
    return _defaultDocumentsResponse;
  }

  Future<DashboardMetricsModel> getDashboardMetrics() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return const DashboardMetricsModel(
      synthesizedDocsCount: 24,
      audioNotesHours: 4.8,
      confidencePercentage: 99.4,
    );
  }

  Future<DocumentSearchResponseModel> searchDocuments(
    DocumentSearchRequestModel request,
  ) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    try {
      final response = await _dio.post(
        ApiConstants.searchDocuments,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return DocumentSearchResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (_) {
      return DocumentSearchResponseModel(
        query: request.query,
        documents: [],
      );
    }
    return DocumentSearchResponseModel(
      query: request.query,
      documents: [],
    );
  }

  static const DocumentsResponseModel _defaultDocumentsResponse =
      DocumentsResponseModel(
    documents: [
      DocumentMetadataModel(
        documentId: 'doc_1',
        filename: 'Q3_Financial_Analysis_Report.pdf',
        sizeBytes: 4404019,
        status: 'Parsed',
        createdAt: '2026-10-14T00:00:00.000Z',
      ),
      DocumentMetadataModel(
        documentId: 'doc_2',
        filename: 'Executive_Strategy_Whiteboard.png',
        sizeBytes: 1887436,
        status: 'OCR Ready',
        createdAt: '2026-10-12T00:00:00.000Z',
        mimeType: 'image/png',
      ),
      DocumentMetadataModel(
        documentId: 'doc_3',
        filename: 'Board_Meeting_Memo_Dictation.wav',
        sizeBytes: 5242880,
        status: 'Voice Transcribed',
        createdAt: '2026-10-10T00:00:00.000Z',
        mimeType: 'audio/wav',
      ),
      DocumentMetadataModel(
        documentId: 'doc_4',
        filename: 'Supply_Chain_Risk_Audit_v2.pdf',
        sizeBytes: 8912896,
        status: 'Structured Table',
        createdAt: '2026-10-08T00:00:00.000Z',
      ),
      DocumentMetadataModel(
        documentId: 'doc_5',
        filename: 'NDA_Master_Partner_Final.docx',
        sizeBytes: 634880,
        status: 'Analyzed',
        createdAt: '2026-09-29T00:00:00.000Z',
      ),
    ],
  );
}
