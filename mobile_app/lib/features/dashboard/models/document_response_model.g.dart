// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentMetadataModel _$DocumentMetadataModelFromJson(
  Map<String, dynamic> json,
) => _DocumentMetadataModel(
  documentId: json['document_id'] as String? ?? '',
  id: json['id'] as String? ?? '',
  filename: json['filename'] as String? ?? 'Untitled',
  sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'completed',
  createdAt: json['created_at'] as String?,
  cloudinaryUrl: json['cloudinary_url'] as String?,
  mimeType: json['mime_type'] as String?,
);

Map<String, dynamic> _$DocumentMetadataModelToJson(
  _DocumentMetadataModel instance,
) => <String, dynamic>{
  'document_id': instance.documentId,
  'id': instance.id,
  'filename': instance.filename,
  'size_bytes': instance.sizeBytes,
  'status': instance.status,
  'created_at': instance.createdAt,
  'cloudinary_url': instance.cloudinaryUrl,
  'mime_type': instance.mimeType,
};

_DocumentsResponseModel _$DocumentsResponseModelFromJson(
  Map<String, dynamic> json,
) => _DocumentsResponseModel(
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map(
            (e) => DocumentMetadataModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$DocumentsResponseModelToJson(
  _DocumentsResponseModel instance,
) => <String, dynamic>{'documents': instance.documents};
