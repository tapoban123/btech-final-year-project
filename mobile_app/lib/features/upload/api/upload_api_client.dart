/// API Client for file uploading and multimodal voice ingestion operations.
class UploadApiClient {
  final Duration networkDelay;

  UploadApiClient({this.networkDelay = Duration.zero});

  Future<List<Map<String, dynamic>>> getRecentUploadsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    // Production environment: Starts empty until user uploads files
    return [];
  }

  Future<Map<String, dynamic>> uploadFileRaw(
    String filename,
    String fileType,
  ) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return {
      'id': 'up_${DateTime.now().millisecondsSinceEpoch}',
      'title': filename,
      'type': fileType,
      'stageDescription': 'Initiating semantic vector indexing',
      'status': 'processing',
    };
  }

  Future<Map<String, dynamic>> saveVoiceMemoRaw(int durationSeconds) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return {
      'id': 'memo_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Voice_Memo_${DateTime.now().millisecondsSinceEpoch}.m4a',
      'type': 'audio',
      'stageDescription': 'Transcribing and indexing audio vectors',
      'status': 'processing',
    };
  }
}
