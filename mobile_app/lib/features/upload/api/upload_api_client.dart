import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// API Client for file uploading and multimodal voice ingestion operations.
class UploadApiClient {
  final Duration networkDelay;
  final String baseUrl;
  final http.Client _client;

  UploadApiClient({
    this.networkDelay = Duration.zero,
    String? baseUrl,
    http.Client? client,
  }) : baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://10.0.2.2:8000',
           ),
       _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getRecentUploadsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    // Production environment: Starts empty until user uploads files
    return [];
  }

  Future<Map<String, dynamic>> uploadFileRaw(
    String filename,
    String fileType, {
    String? filePath,
  }) async {
    if (filePath != null) {
      return uploadPdf(filePath: filePath, filename: filename);
    }

    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return {
      'id': 'up_${DateTime.now().millisecondsSinceEpoch}',
      'title': filename,
      'type': fileType,
      'stageDescription': '',
      'status': 'processing',
    };
  }

  /// Uploads the actual PDF bytes to FastAPI as multipart/form-data.
  Future<Map<String, dynamic>> uploadPdf({
    required String filePath,
    required String filename,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const UploadApiException(
        'LOCAL_FILE_NOT_FOUND',
        'The selected file is no longer available',
      );
    }

    final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/documents/upload'),
      )
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: filename,
        ),
      );

    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(minutes: 2));
      final response = await http.Response.fromStream(streamed);
      final body = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail = body['detail'];
        final code = detail is Map<String, dynamic>
            ? detail['code']?.toString() ?? 'UPLOAD_FAILED'
            : 'UPLOAD_FAILED';
        final message = detail is Map<String, dynamic>
            ? detail['message']?.toString() ?? 'Upload failed'
            : detail?.toString() ?? 'Upload failed';
        throw UploadApiException(code, message, response.statusCode);
      }

      return body;
    } on UploadApiException {
      rethrow;
    } on SocketException catch (error) {
      throw UploadApiException('NETWORK_ERROR', error.message);
    } on TimeoutException {
      throw const UploadApiException('TIMEOUT', 'The upload timed out');
    } catch (error) {
      throw UploadApiException('UPLOAD_FAILED', error.toString());
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'detail': decoded.toString()};
  }

  void dispose() => _client.close();

  Future<Map<String, dynamic>> saveVoiceMemoRaw(int durationSeconds) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return {
      'id': 'memo_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Voice_Memo_${DateTime.now().millisecondsSinceEpoch}.m4a',
      'type': 'audio',
      'stageDescription': '',
      'status': 'processing',
    };
  }
}

class UploadApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const UploadApiException(this.code, this.message, [this.statusCode]);

  @override
  String toString() => message;
}
