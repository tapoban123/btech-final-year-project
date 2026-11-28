import '../../dashboard/repository/models/document_item.dart';
import '../api/upload_api_client.dart';
import '../models/upload_response_model.dart';
import 'models/upload_item.dart';

abstract class IUploadRepository {
  Future<List<UploadItem>> getRecentUploads();
  Future<UploadItem> uploadFile(
    String filename,
    DocumentType type, {
    String? filePath,
    int? fileSize,
  });
  Future<UploadItem> saveVoiceMemo(int durationSeconds);
}

class UploadRepository implements IUploadRepository {
  final UploadApiClient _apiClient;

  UploadRepository({UploadApiClient? apiClient})
      : _apiClient = apiClient ?? UploadApiClient();

  @override
  Future<List<UploadItem>> getRecentUploads() async {
    final list = await _apiClient.getRecentUploads();
    return list.map(_mapUploadResponseToUploadItem).toList();
  }

  @override
  Future<UploadItem> uploadFile(
    String filename,
    DocumentType type, {
    String? filePath,
    int? fileSize,
  }) async {
    final model = await _apiClient.uploadFile(
      filename,
      type.name,
      filePath: filePath,
    );
    final item = _mapUploadResponseToUploadItem(model);
    return item.copyWith(filePath: filePath, fileSize: fileSize);
  }

  @override
  Future<UploadItem> saveVoiceMemo(int durationSeconds) async {
    final memo = await _apiClient.saveVoiceMemo(durationSeconds);
    return UploadItem(
      id: memo.id,
      title: memo.title,
      type: DocumentType.audio,
      stageDescription: memo.stageDescription,
      status: _mapStatus(memo.status),
    );
  }

  UploadItem _mapUploadResponseToUploadItem(DocumentUploadResponseModel model) {
    return UploadItem(
      id: model.resolvedId.isNotEmpty
          ? model.resolvedId
          : 'up_${DateTime.now().millisecondsSinceEpoch}',
      title: model.filename,
      type: _inferDocType(model.filename, model.contentType),
      stageDescription: model.message,
      status: _mapStatus(model.status),
    );
  }

  DocumentType _inferDocType(String filename, String contentType) {
    final lower = filename.toLowerCase();
    if (contentType.startsWith('image/') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return DocumentType.image;
    }
    if (contentType.startsWith('audio/') ||
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

  UploadProcessingStatus _mapStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'completed':
        return UploadProcessingStatus.completed;
      case 'failed':
        return UploadProcessingStatus.failed;
      case 'queued':
        return UploadProcessingStatus.queued;
      case 'processing':
      default:
        return UploadProcessingStatus.processing;
    }
  }
}
