import 'package:equatable/equatable.dart';
import '../../../dashboard/repository/models/document_item.dart';

enum MessageSender {
  user,
  assistant,
}

class CitationItem extends Equatable {
  final String title;
  final String reference;
  final DocumentType type;

  const CitationItem({
    required this.title,
    required this.reference,
    required this.type,
  });

  @override
  List<Object?> get props => [title, reference, type];
}

class SynthesisPoint extends Equatable {
  final int number;
  final String title;
  final String description;
  final String? highlight;

  const SynthesisPoint({
    required this.number,
    required this.title,
    required this.description,
    this.highlight,
  });

  @override
  List<Object?> get props => [number, title, description, highlight];
}

class ChatMessage extends Equatable {
  final String id;
  final MessageSender sender;
  final String content;
  final String timestamp;
  final List<SynthesisPoint> synthesisPoints;
  final List<CitationItem> citations;
  final bool isAccurateFeedbackGiven;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.synthesisPoints = const [],
    this.citations = const [],
    this.isAccurateFeedbackGiven = false,
  });

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    String? timestamp,
    List<SynthesisPoint>? synthesisPoints,
    List<CitationItem>? citations,
    bool? isAccurateFeedbackGiven,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      synthesisPoints: synthesisPoints ?? this.synthesisPoints,
      citations: citations ?? this.citations,
      isAccurateFeedbackGiven:
          isAccurateFeedbackGiven ?? this.isAccurateFeedbackGiven,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        content,
        timestamp,
        synthesisPoints,
        citations,
        isAccurateFeedbackGiven,
      ];
}

class ActiveRAGContext extends Equatable {
  final String id;
  final String title;
  final DocumentType type;

  const ActiveRAGContext({
    required this.id,
    required this.title,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, type];
}
