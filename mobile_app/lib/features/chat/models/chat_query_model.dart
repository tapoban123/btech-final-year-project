import 'package:freezed_annotation/freezed_annotation.dart';
import '../../dashboard/models/document_response_model.dart';

part 'chat_query_model.freezed.dart';
part 'chat_query_model.g.dart';

@freezed
abstract class DocumentQueryRequestModel with _$DocumentQueryRequestModel {
  const factory DocumentQueryRequestModel({
    required String query,
  }) = _DocumentQueryRequestModel;

  factory DocumentQueryRequestModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentQueryRequestModelFromJson(json);
}

@freezed
abstract class QueryCitationModel with _$QueryCitationModel {
  const factory QueryCitationModel({
    @JsonKey(name: 'document_id') @Default('') String documentId,
    @JsonKey(name: 'document_name') @Default('') String documentName,
    @Default(1) int page,
    String? snippet,
    @JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,
    @JsonKey(name: 'mime_type') String? mimeType,
  }) = _QueryCitationModel;

  factory QueryCitationModel.fromJson(Map<String, dynamic> json) =>
      _$QueryCitationModelFromJson(json);
}

@freezed
abstract class MultiDocumentQueryResponseModel
    with _$MultiDocumentQueryResponseModel {
  const factory MultiDocumentQueryResponseModel({
    @Default('') String answer,
    @Default([]) List<QueryCitationModel> sources,
    @Default([]) List<DocumentMetadataModel> documents,
  }) = _MultiDocumentQueryResponseModel;

  factory MultiDocumentQueryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MultiDocumentQueryResponseModelFromJson(json);
}
