import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_search_model.freezed.dart';
part 'document_search_model.g.dart';

@freezed
abstract class DocumentSearchRequestModel with _$DocumentSearchRequestModel {
  const factory DocumentSearchRequestModel({
    required String query,
  }) = _DocumentSearchRequestModel;

  factory DocumentSearchRequestModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentSearchRequestModelFromJson(json);
}

@freezed
abstract class DocumentSearchResultModel with _$DocumentSearchResultModel {
  const factory DocumentSearchResultModel({
    @JsonKey(name: 'document_id') required String documentId,
    required String filename,
    @JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,
    double? score,
  }) = _DocumentSearchResultModel;

  factory DocumentSearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentSearchResultModelFromJson(json);
}

@freezed
abstract class DocumentSearchResponseModel with _$DocumentSearchResponseModel {
  const factory DocumentSearchResponseModel({
    required String query,
    @Default([]) List<DocumentSearchResultModel> documents,
  }) = _DocumentSearchResponseModel;

  factory DocumentSearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentSearchResponseModelFromJson(json);
}
