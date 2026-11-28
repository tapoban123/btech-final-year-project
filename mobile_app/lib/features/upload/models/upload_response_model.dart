import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_response_model.freezed.dart';
part 'upload_response_model.g.dart';

@freezed
abstract class DocumentUploadResponseModel with _$DocumentUploadResponseModel {
  const DocumentUploadResponseModel._();

  const factory DocumentUploadResponseModel({
    String? id,
    @JsonKey(name: 'document_id') String? documentId,
    @Default('') String filename,
    @JsonKey(name: 'content_type') @Default('') String contentType,
    @JsonKey(name: 'size_bytes') @Default(0) int sizeBytes,
    @Default('completed') String status,
    @Default('') String message,
    @JsonKey(name: 'cloudinary_public_id') String? cloudinaryPublicId,
  }) = _DocumentUploadResponseModel;

  String get resolvedId => (documentId != null && documentId!.isNotEmpty)
      ? documentId!
      : (id ?? '');

  factory DocumentUploadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadResponseModelFromJson(json);
}

@freezed
abstract class DocumentBatchUploadResponseModel
    with _$DocumentBatchUploadResponseModel {
  const factory DocumentBatchUploadResponseModel({
    @JsonKey(name: 'total_files') @Default(0) int totalFiles,
    @Default(0) int successful,
    @Default(0) int failed,
    @Default([]) List<DocumentUploadResponseModel> results,
  }) = _DocumentBatchUploadResponseModel;

  factory DocumentBatchUploadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentBatchUploadResponseModelFromJson(json);
}

@freezed
abstract class VoiceMemoResponseModel with _$VoiceMemoResponseModel {
  const factory VoiceMemoResponseModel({
    required String id,
    required String title,
    @Default('audio') String type,
    @JsonKey(name: 'stage_description') @Default('') String stageDescription,
    @Default('processing') String status,
  }) = _VoiceMemoResponseModel;

  factory VoiceMemoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceMemoResponseModelFromJson(json);
}
