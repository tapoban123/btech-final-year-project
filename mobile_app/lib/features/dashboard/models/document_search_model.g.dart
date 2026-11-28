// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentSearchRequestModel _$DocumentSearchRequestModelFromJson(
  Map<String, dynamic> json,
) => _DocumentSearchRequestModel(query: json['query'] as String);

Map<String, dynamic> _$DocumentSearchRequestModelToJson(
  _DocumentSearchRequestModel instance,
) => <String, dynamic>{'query': instance.query};

_DocumentSearchResultModel _$DocumentSearchResultModelFromJson(
  Map<String, dynamic> json,
) => _DocumentSearchResultModel(
  documentId: json['document_id'] as String,
  filename: json['filename'] as String,
  cloudinaryUrl: json['cloudinary_url'] as String?,
  score: (json['score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DocumentSearchResultModelToJson(
  _DocumentSearchResultModel instance,
) => <String, dynamic>{
  'document_id': instance.documentId,
  'filename': instance.filename,
  'cloudinary_url': instance.cloudinaryUrl,
  'score': instance.score,
};

_DocumentSearchResponseModel _$DocumentSearchResponseModelFromJson(
  Map<String, dynamic> json,
) => _DocumentSearchResponseModel(
  query: json['query'] as String,
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map(
            (e) =>
                DocumentSearchResultModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$DocumentSearchResponseModelToJson(
  _DocumentSearchResponseModel instance,
) => <String, dynamic>{
  'query': instance.query,
  'documents': instance.documents,
};
