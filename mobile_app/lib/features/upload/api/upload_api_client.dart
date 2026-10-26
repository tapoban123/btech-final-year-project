/// API Client for file uploading and multimodal voice ingestion operations.
class UploadApiClient {
  final Duration networkDelay;

  UploadApiClient({this.networkDelay = Duration.zero});

  Future<List<Map<String, dynamic>>> getRecentUploadsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }

    return [
      {
        'id': 'up_1',
        'title': 'Vendor_Contract_2025_Final.pdf',
        'type': 'pdf',
        'stageDescription': 'Analyzing semantic vectors',
        'status': 'processing',
      },
      {
        'id': 'up_2',
        'title': 'Product_Roadmap_Q4.png',
        'type': 'image',
        'stageDescription': 'OCR text extraction',
        'status': 'processing',
      },
      {
        'id': 'up_3',
        'title': 'Partner_Sync_Audio_Call.m4a',
        'type': 'audio',
        'stageDescription': 'Transcribing audio',
        'status': 'processing',
      },
    ];
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
