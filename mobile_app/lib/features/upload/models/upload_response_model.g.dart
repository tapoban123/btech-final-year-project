// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentUploadResponseModel _$DocumentUploadResponseModelFromJson(
  Map<String, dynamic> json,
) => _DocumentUploadResponseModel(
  id: json['id'] as String?,
  documentId: json['document_id'] as String?,
  filename: json['filename'] as String? ?? '',
  contentType: json['content_type'] as String? ?? '',
  sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'completed',
  message: json['message'] as String? ?? '',
  cloudinaryPublicId: json['cloudinary_public_id'] as String?,
);

Map<String, dynamic> _$DocumentUploadResponseModelToJson(
  _DocumentUploadResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'document_id': instance.documentId,
  'filename': instance.filename,
  'content_type': instance.contentType,
  'size_bytes': instance.sizeBytes,
  'status': instance.status,
  'message': instance.message,
  'cloudinary_public_id': instance.cloudinaryPublicId,
};

_DocumentBatchUploadResponseModel _$DocumentBatchUploadResponseModelFromJson(
  Map<String, dynamic> json,
) => _DocumentBatchUploadResponseModel(
  totalFiles: (json['total_files'] as num?)?.toInt() ?? 0,
  successful: (json['successful'] as num?)?.toInt() ?? 0,
  failed: (json['failed'] as num?)?.toInt() ?? 0,
  results:
      (json['results'] as List<dynamic>?)
          ?.map(
            (e) =>
                DocumentUploadResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$DocumentBatchUploadResponseModelToJson(
  _DocumentBatchUploadResponseModel instance,
) => <String, dynamic>{
  'total_files': instance.totalFiles,
  'successful': instance.successful,
  'failed': instance.failed,
  'results': instance.results,
};

_VoiceMemoResponseModel _$VoiceMemoResponseModelFromJson(
  Map<String, dynamic> json,
) => _VoiceMemoResponseModel(
  id: json['id'] as String,
  title: json['title'] as String,
  type: json['type'] as String? ?? 'audio',
  stageDescription: json['stage_description'] as String? ?? '',
  status: json['status'] as String? ?? 'processing',
);

Map<String, dynamic> _$VoiceMemoResponseModelToJson(
  _VoiceMemoResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': instance.type,
  'stage_description': instance.stageDescription,
  'status': instance.status,
};
