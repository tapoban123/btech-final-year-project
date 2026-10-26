import '../../../core/utils/app_formatters.dart';

/// API Client for dashboard document intelligence operations.
/// Follows Clean Code separation of API interactions from business repository logic.
class DocumentApiClient {
  final Duration networkDelay;

  DocumentApiClient({this.networkDelay = Duration.zero});

  Future<List<Map<String, dynamic>>> getDocumentsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return [
      {
        'id': 'doc_1',
        'title': 'Q3_Financial_Analysis_Report.pdf',
        'type': 'pdf',
        'fileSize': AppFormatters.formatFileSizeInMb(4.2),
        'date': AppFormatters.formatDate(DateTime(2026, 10, 14)),
        'statusTag': 'Parsed',
        'isStatusHighlighted': true,
        'isSelected': true,
      },
      {
        'id': 'doc_2',
        'title': 'Executive_Strategy_Whiteboard.png',
        'type': 'image',
        'fileSize': AppFormatters.formatFileSizeInMb(1.8),
        'date': AppFormatters.formatDate(DateTime(2026, 10, 12)),
        'statusTag': 'OCR Ready',
        'isStatusHighlighted': false,
        'isSelected': false,
      },
      {
        'id': 'doc_3',
        'title': 'Board_Meeting_Memo_Dictation.wav',
        'type': 'audio',
        'fileSize': '${AppFormatters.formatDuration(865)} min',
        'date': AppFormatters.formatDate(DateTime(2026, 10, 10)),
        'statusTag': 'Voice Transcribed',
        'isStatusHighlighted': true,
        'duration': '${AppFormatters.formatDuration(865)} min',
        'isSelected': false,
      },
      {
        'id': 'doc_4',
        'title': 'Supply_Chain_Risk_Audit_v2.pdf',
        'type': 'pdf',
        'fileSize': AppFormatters.formatFileSizeInMb(8.5),
        'date': AppFormatters.formatDate(DateTime(2026, 10, 8)),
        'statusTag': 'Structured Table',
        'isStatusHighlighted': false,
        'isSelected': false,
      },
      {
        'id': 'doc_5',
        'title': 'NDA_Master_Partner_Final.docx',
        'type': 'docx',
        'fileSize': '${AppFormatters.formatNumber(620)} KB',
        'date': AppFormatters.formatDate(DateTime(2026, 9, 29)),
        'statusTag': 'Analyzed',
        'isStatusHighlighted': true,
        'isSelected': false,
      },
    ];
  }

  Future<Map<String, dynamic>> getDashboardMetricsRaw() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return {
      'synthesizedDocsCount': 24,
      'audioNotesHours': 4.8,
      'confidencePercentage': 99.4,
    };
  }
}
