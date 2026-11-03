import '../../dashboard/repository/models/document_item.dart';
import '../api/upload_api_client.dart';
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
    final rawList = await _apiClient.getRecentUploadsRaw();
    return rawList.map((item) => _mapToUploadItem(item)).toList();
  }

  @override
  Future<UploadItem> uploadFile(
    String filename,
    DocumentType type, {
    String? filePath,
    int? fileSize,
  }) async {
    final raw = await _apiClient.uploadFileRaw(filename, type.name);
    final item = _mapToUploadItem(raw);
    return item.copyWith(filePath: filePath, fileSize: fileSize);
  }

  @override
  Future<UploadItem> saveVoiceMemo(int durationSeconds) async {
    final raw = await _apiClient.saveVoiceMemoRaw(durationSeconds);
    return _mapToUploadItem(raw);
  }

  UploadItem _mapToUploadItem(Map<String, dynamic> raw) {
    final typeStr = raw['type'] as String? ?? 'pdf';
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

    final statusStr = raw['status'] as String? ?? 'processing';
    final UploadProcessingStatus status;
    switch (statusStr) {
      case 'completed':
        status = UploadProcessingStatus.completed;
        break;
      case 'failed':
        status = UploadProcessingStatus.failed;
        break;
      case 'processing':
      default:
        status = UploadProcessingStatus.processing;
        break;
    }

    return UploadItem(
      id: raw['id'] as String,
      title: raw['title'] as String,
      type: docType,
      stageDescription: raw['stageDescription'] as String? ?? '',
      status: status,
    );
  }
}
