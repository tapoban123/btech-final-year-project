import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_response_model.freezed.dart';
part 'document_response_model.g.dart';

@freezed
abstract class DocumentMetadataModel with _$DocumentMetadataModel {
  const DocumentMetadataModel._();

  const factory DocumentMetadataModel({
    @JsonKey(name: 'document_id') @Default('') String documentId,
    @Default('') String id,
    @Default('Untitled') String filename,
    @JsonKey(name: 'size_bytes') @Default(0) int sizeBytes,
    @Default('completed') String status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,
    @JsonKey(name: 'mime_type') String? mimeType,
  }) = _DocumentMetadataModel;

  String get resolvedId => documentId.isNotEmpty ? documentId : id;

  factory DocumentMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentMetadataModelFromJson(json);
}

@freezed
abstract class DocumentsResponseModel with _$DocumentsResponseModel {
  const factory DocumentsResponseModel({
    @Default([]) List<DocumentMetadataModel> documents,
  }) = _DocumentsResponseModel;

  factory DocumentsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentsResponseModelFromJson(json);
}
