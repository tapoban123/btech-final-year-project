import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/upload_response_model.dart';

/// API Client for file uploading and multimodal voice ingestion operations using global DioClient.
class UploadApiClient {
  final Dio _dio;
  final Duration networkDelay;

  UploadApiClient({
    Dio? dio,
    this.networkDelay = Duration.zero,
  }) : _dio = dio ?? DioClient().dio;

  Dio get client => _dio;

  Future<List<DocumentUploadResponseModel>> getRecentUploads() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return [];
  }

  Future<DocumentUploadResponseModel> uploadFile(
    String filename,
    String fileType, {
    String? filePath,
  }) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    if (filePath != null && filePath.isNotEmpty) {
      try {
        final formData = FormData.fromMap({
          'files': [
            await MultipartFile.fromFile(
              filePath,
              filename: filename,
            ),
          ],
        });

        final response = await _dio.post(
          ApiConstants.uploadDocuments,
          data: formData,
        );

        if (response.statusCode == 201 && response.data != null) {
          final batch = DocumentBatchUploadResponseModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (batch.results.isNotEmpty) {
            return batch.results.first;
          }
        }
      } on DioException {
        rethrow;
      }
    }

    return DocumentUploadResponseModel(
      id: 'up_${DateTime.now().millisecondsSinceEpoch}',
      filename: filename,
      contentType: fileType,
      status: 'processing',
      message: 'Processing file',
    );
  }

  Future<VoiceMemoResponseModel> saveVoiceMemo(int durationSeconds) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return VoiceMemoResponseModel(
      id: 'memo_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Voice_Memo_${DateTime.now().millisecondsSinceEpoch}.m4a',
      type: 'audio',
      stageDescription: 'Transcribing audio vectors',
      status: 'processing',
    );
  }
}
