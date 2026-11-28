// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_query_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentQueryRequestModel _$DocumentQueryRequestModelFromJson(
  Map<String, dynamic> json,
) => _DocumentQueryRequestModel(query: json['query'] as String);

Map<String, dynamic> _$DocumentQueryRequestModelToJson(
  _DocumentQueryRequestModel instance,
) => <String, dynamic>{'query': instance.query};

_QueryCitationModel _$QueryCitationModelFromJson(Map<String, dynamic> json) =>
    _QueryCitationModel(
      documentId: json['document_id'] as String? ?? '',
      documentName: json['document_name'] as String? ?? '',
      page: (json['page'] as num?)?.toInt() ?? 1,
      snippet: json['snippet'] as String?,
      cloudinaryUrl: json['cloudinary_url'] as String?,
      mimeType: json['mime_type'] as String?,
    );

Map<String, dynamic> _$QueryCitationModelToJson(_QueryCitationModel instance) =>
    <String, dynamic>{
      'document_id': instance.documentId,
      'document_name': instance.documentName,
      'page': instance.page,
      'snippet': instance.snippet,
      'cloudinary_url': instance.cloudinaryUrl,
      'mime_type': instance.mimeType,
    };

_MultiDocumentQueryResponseModel _$MultiDocumentQueryResponseModelFromJson(
  Map<String, dynamic> json,
) => _MultiDocumentQueryResponseModel(
  answer: json['answer'] as String? ?? '',
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => QueryCitationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map(
            (e) => DocumentMetadataModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MultiDocumentQueryResponseModelToJson(
  _MultiDocumentQueryResponseModel instance,
) => <String, dynamic>{
  'answer': instance.answer,
  'sources': instance.sources,
  'documents': instance.documents,
};
