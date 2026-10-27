import 'package:equatable/equatable.dart';
import '../../../core/utils/app_formatters.dart';
import '../repository/models/upload_item.dart';

enum UploadScreenStatus { initial, loading, success, failure }

class UploadState extends Equatable {
  final UploadScreenStatus status;
  final List<UploadItem> recentUploads;
  final bool isRecording;
  final int recordingDurationSeconds;
  final String speechDetectionMessage;
  final String? errorMessage;

  const UploadState({
    this.status = UploadScreenStatus.initial,
    this.recentUploads = const [],
    this.isRecording = false,
    this.recordingDurationSeconds = 0,
    this.speechDetectionMessage =
        'Listening: Multimodal vector ingestion live',
    this.errorMessage,
  });

  String get formattedDuration =>
      AppFormatters.formatDuration(recordingDurationSeconds);

  int get activeUploadsCount => recentUploads
      .where((u) => u.status == UploadProcessingStatus.processing)
      .length;

  UploadState copyWith({
    UploadScreenStatus? status,
    List<UploadItem>? recentUploads,
    bool? isRecording,
    int? recordingDurationSeconds,
    String? speechDetectionMessage,
    String? errorMessage,
  }) {
    return UploadState(
      status: status ?? this.status,
      recentUploads: recentUploads ?? this.recentUploads,
      isRecording: isRecording ?? this.isRecording,
      recordingDurationSeconds:
          recordingDurationSeconds ?? this.recordingDurationSeconds,
      speechDetectionMessage:
          speechDetectionMessage ?? this.speechDetectionMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recentUploads,
        isRecording,
        recordingDurationSeconds,
        speechDetectionMessage,
        errorMessage,
      ];
}
