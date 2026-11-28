// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SynthesisPointModel _$SynthesisPointModelFromJson(Map<String, dynamic> json) =>
    _SynthesisPointModel(
      number: (json['number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      highlight: json['highlight'] as String?,
    );

Map<String, dynamic> _$SynthesisPointModelToJson(
  _SynthesisPointModel instance,
) => <String, dynamic>{
  'number': instance.number,
  'title': instance.title,
  'description': instance.description,
  'highlight': instance.highlight,
};

_ChatCitationModel _$ChatCitationModelFromJson(Map<String, dynamic> json) =>
    _ChatCitationModel(
      title: json['title'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      type: json['type'] as String? ?? 'pdf',
      cloudinaryUrl: json['cloudinary_url'] as String?,
    );

Map<String, dynamic> _$ChatCitationModelToJson(_ChatCitationModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'reference': instance.reference,
      'type': instance.type,
      'cloudinary_url': instance.cloudinaryUrl,
    };

_ChatHistoryItemModel _$ChatHistoryItemModelFromJson(
  Map<String, dynamic> json,
) => _ChatHistoryItemModel(
  id: json['id'] as String,
  sender: json['sender'] as String? ?? 'user',
  content: json['content'] as String? ?? '',
  timestamp: json['timestamp'] as String? ?? '',
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => SynthesisPointModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  citations:
      (json['citations'] as List<dynamic>?)
          ?.map((e) => ChatCitationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ChatHistoryItemModelToJson(
  _ChatHistoryItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender': instance.sender,
  'content': instance.content,
  'timestamp': instance.timestamp,
  'points': instance.points,
  'citations': instance.citations,
};

_ActiveRAGContextModel _$ActiveRAGContextModelFromJson(
  Map<String, dynamic> json,
) => _ActiveRAGContextModel(
  id: json['id'] as String,
  title: json['title'] as String,
  type: json['type'] as String? ?? 'pdf',
);

Map<String, dynamic> _$ActiveRAGContextModelToJson(
  _ActiveRAGContextModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': instance.type,
};
