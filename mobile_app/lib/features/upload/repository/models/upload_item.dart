import 'package:equatable/equatable.dart';
import '../../../dashboard/repository/models/document_item.dart';

enum UploadProcessingStatus {
  queued,
  processing,
  completed,
  failed,
}

class UploadItem extends Equatable {
  final String id;
  final String title;
  final DocumentType type;
  final String stageDescription;
  final UploadProcessingStatus status;
  final double? progress;
  final String? filePath;
  final int? fileSize;

  const UploadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.stageDescription,
    this.status = UploadProcessingStatus.processing,
    this.progress,
    this.filePath,
    this.fileSize,
  });

  UploadItem copyWith({
    String? id,
    String? title,
    DocumentType? type,
    String? stageDescription,
    UploadProcessingStatus? status,
    double? progress,
    String? filePath,
    int? fileSize,
  }) {
    return UploadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      stageDescription: stageDescription ?? this.stageDescription,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        stageDescription,
        status,
        progress,
        filePath,
        fileSize,
      ];
}
