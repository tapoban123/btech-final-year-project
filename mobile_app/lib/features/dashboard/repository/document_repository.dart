import '../api/document_api_client.dart';
import 'models/document_item.dart';

abstract class IDocumentRepository {
  Future<List<DocumentItem>> getDocuments();
  Future<DashboardMetrics> getMetrics();
}

class DocumentRepository implements IDocumentRepository {
  final DocumentApiClient _apiClient;

  DocumentRepository({DocumentApiClient? apiClient})
      : _apiClient = apiClient ?? DocumentApiClient();

  @override
  Future<List<DocumentItem>> getDocuments() async {
    final rawList = await _apiClient.getDocumentsRaw();
    return rawList.map((item) {
      final typeString = item['type'] as String? ?? 'pdf';
      final DocumentType docType;
      switch (typeString) {
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

      return DocumentItem(
        id: item['id'] as String,
        title: item['title'] as String,
        type: docType,
        fileSize: item['fileSize'] as String,
        date: item['date'] as String,
        statusTag: item['statusTag'] as String,
        isStatusHighlighted: item['isStatusHighlighted'] as bool? ?? false,
        duration: item['duration'] as String?,
        isSelected: item['isSelected'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<DashboardMetrics> getMetrics() async {
    final rawMetrics = await _apiClient.getDashboardMetricsRaw();
    return DashboardMetrics(
      synthesizedDocsCount: rawMetrics['synthesizedDocsCount'] as int? ?? 24,
      audioNotesHours: (rawMetrics['audioNotesHours'] as num?)?.toDouble() ?? 4.8,
      confidencePercentage:
          (rawMetrics['confidencePercentage'] as num?)?.toDouble() ?? 99.4,
    );
  }
}
