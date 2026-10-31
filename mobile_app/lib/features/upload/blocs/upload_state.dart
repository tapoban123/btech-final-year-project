import 'package:equatable/equatable.dart';
import '../../../core/utils/app_formatters.dart';
import '../repository/models/upload_item.dart';

enum UploadScreenStatus { initial, loading, success, failure }

class UploadState extends Equatable {
  final UploadScreenStatus status;
  final List<UploadItem> recentUploads;
  final bool isRecordingCardVisible;
  final bool isRecording;
  final bool isUploading;
  final int recordingDurationSeconds;
  final double currentAmplitude;
  final String speechDetectionMessage;
  final String? errorMessage;

  const UploadState({
    this.status = UploadScreenStatus.initial,
    this.recentUploads = const [],
    this.isRecordingCardVisible = false,
    this.isRecording = false,
    this.isUploading = false,
    this.recordingDurationSeconds = 0,
    this.currentAmplitude = 0.0,
    this.speechDetectionMessage = 'Listening...',
    this.errorMessage,
  });

  bool get isRecorderOpen => isRecordingCardVisible || isRecording;

  String get formattedDuration =>
      AppFormatters.formatDuration(recordingDurationSeconds);

  int get activeUploadsCount => recentUploads
      .where((u) =>
          u.status == UploadProcessingStatus.processing ||
          u.status == UploadProcessingStatus.queued)
      .length;

  UploadState copyWith({
    UploadScreenStatus? status,
    List<UploadItem>? recentUploads,
    bool? isRecordingCardVisible,
    bool? isRecording,
    bool? isUploading,
    int? recordingDurationSeconds,
    double? currentAmplitude,
    String? speechDetectionMessage,
    String? errorMessage,
  }) {
    return UploadState(
      status: status ?? this.status,
      recentUploads: recentUploads ?? this.recentUploads,
      isRecordingCardVisible:
          isRecordingCardVisible ?? this.isRecordingCardVisible,
      isRecording: isRecording ?? this.isRecording,
      isUploading: isUploading ?? this.isUploading,
      recordingDurationSeconds:
          recordingDurationSeconds ?? this.recordingDurationSeconds,
      currentAmplitude: currentAmplitude ?? this.currentAmplitude,
      speechDetectionMessage:
          speechDetectionMessage ?? this.speechDetectionMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recentUploads,
        isRecordingCardVisible,
        isRecording,
        isUploading,
        recordingDurationSeconds,
        currentAmplitude,
        speechDetectionMessage,
        errorMessage,
      ];
}
