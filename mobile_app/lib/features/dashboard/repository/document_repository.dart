import '../../../core/utils/app_formatters.dart';
import '../api/document_api_client.dart';
import '../models/document_response_model.dart';
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
    final response = await _apiClient.getDocuments();
    return response.documents.map(_mapToDocumentItem).toList();
  }

  @override
  Future<DashboardMetrics> getMetrics() async {
    final metrics = await _apiClient.getDashboardMetrics();
    return DashboardMetrics(
      synthesizedDocsCount: metrics.synthesizedDocsCount,
      audioNotesHours: metrics.audioNotesHours,
      confidencePercentage: metrics.confidencePercentage,
    );
  }

  DocumentItem _mapToDocumentItem(DocumentMetadataModel doc) {
    final filename = doc.filename;
    final mimeType = doc.mimeType ?? '';
    final type = _inferType(filename, mimeType);
    final isAudio = type == DocumentType.audio;

    final createdAt = doc.createdAt != null
        ? DateTime.tryParse(doc.createdAt!) ?? DateTime.now()
        : DateTime.now();

    final durationStr =
        isAudio ? '${AppFormatters.formatDuration(865)} min' : null;

    final fileSizeStr = isAudio
        ? (durationStr ?? '')
        : (filename.toLowerCase().endsWith('.docx')
            ? '${AppFormatters.formatNumber((doc.sizeBytes / 1024).round())} KB'
            : AppFormatters.formatFileSizeInMb(doc.sizeBytes / (1024 * 1024)));

    return DocumentItem(
      id: doc.resolvedId,
      title: filename,
      type: type,
      fileSize: fileSizeStr,
      date: AppFormatters.formatDate(createdAt),
      statusTag: _formatStatusTag(doc.status),
      isStatusHighlighted: doc.status.toLowerCase() == 'completed' ||
          doc.status == 'Parsed' ||
          doc.status == 'Voice Transcribed' ||
          doc.status == 'Analyzed',
      duration: durationStr,
      isSelected: false,
    );
  }

  DocumentType _inferType(String filename, String mimeType) {
    final lower = filename.toLowerCase();
    if (mimeType.startsWith('image/') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return DocumentType.image;
    }
    if (mimeType.startsWith('audio/') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a')) {
      return DocumentType.audio;
    }
    if (lower.endsWith('.docx') || lower.endsWith('.doc')) {
      return DocumentType.docx;
    }
    return DocumentType.pdf;
  }

  String _formatStatusTag(String? status) {
    if (status == null || status.isEmpty) return 'Ready';
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Parsed';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}
