import 'package:equatable/equatable.dart';
import '../../../dashboard/repository/models/document_item.dart';

enum UploadProcessingStatus {
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

  const UploadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.stageDescription,
    this.status = UploadProcessingStatus.processing,
    this.progress,
  });

  UploadItem copyWith({
    String? id,
    String? title,
    DocumentType? type,
    String? stageDescription,
    UploadProcessingStatus? status,
    double? progress,
  }) {
    return UploadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      stageDescription: stageDescription ?? this.stageDescription,
      status: status ?? this.status,
      progress: progress ?? this.progress,
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
      ];
}
