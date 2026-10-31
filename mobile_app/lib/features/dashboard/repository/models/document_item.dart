import 'package:equatable/equatable.dart';

enum DocumentType {
  pdf,
  image,
  audio,
  docx,
}

enum DocumentFilterCategory {
  all,
  reports,
  recordings,
  diagrams,
}

class DocumentItem extends Equatable {
  final String id;
  final String title;
  final DocumentType type;
  final String fileSize;
  final String date;
  final String statusTag;
  final bool isStatusHighlighted;
  final String? duration;
  final bool isSelected;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.fileSize,
    required this.date,
    required this.statusTag,
    this.isStatusHighlighted = false,
    this.duration,
    this.isSelected = false,
  });

  DocumentItem copyWith({
    String? id,
    String? title,
    DocumentType? type,
    String? fileSize,
    String? date,
    String? statusTag,
    bool? isStatusHighlighted,
    String? duration,
    bool? isSelected,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      date: date ?? this.date,
      statusTag: statusTag ?? this.statusTag,
      isStatusHighlighted: isStatusHighlighted ?? this.isStatusHighlighted,
      duration: duration ?? this.duration,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        fileSize,
        date,
        statusTag,
        isStatusHighlighted,
        duration,
        isSelected,
      ];
}

class DashboardMetrics extends Equatable {
  final int synthesizedDocsCount;
  final double audioNotesHours;
  final double confidencePercentage;

  const DashboardMetrics({
    required this.synthesizedDocsCount,
    required this.audioNotesHours,
    required this.confidencePercentage,
  });

  @override
  List<Object?> get props => [
        synthesizedDocsCount,
        audioNotesHours,
        confidencePercentage,
      ];
}
