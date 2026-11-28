import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_history_model.freezed.dart';
part 'chat_history_model.g.dart';

@freezed
abstract class SynthesisPointModel with _$SynthesisPointModel {
  const factory SynthesisPointModel({
    @Default(1) int number,
    @Default('') String title,
    @Default('') String description,
    String? highlight,
  }) = _SynthesisPointModel;

  factory SynthesisPointModel.fromJson(Map<String, dynamic> json) =>
      _$SynthesisPointModelFromJson(json);
}

@freezed
abstract class ChatCitationModel with _$ChatCitationModel {
  const factory ChatCitationModel({
    @Default('') String title,
    @Default('') String reference,
    @Default('pdf') String type,
    @JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,
  }) = _ChatCitationModel;

  factory ChatCitationModel.fromJson(Map<String, dynamic> json) =>
      _$ChatCitationModelFromJson(json);
}

@freezed
abstract class ChatHistoryItemModel with _$ChatHistoryItemModel {
  const factory ChatHistoryItemModel({
    required String id,
    @Default('user') String sender,
    @Default('') String content,
    @Default('') String timestamp,
    @Default([]) List<SynthesisPointModel> points,
    @Default([]) List<ChatCitationModel> citations,
  }) = _ChatHistoryItemModel;

  factory ChatHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryItemModelFromJson(json);
}

@freezed
abstract class ActiveRAGContextModel with _$ActiveRAGContextModel {
  const factory ActiveRAGContextModel({
    required String id,
    required String title,
    @Default('pdf') String type,
  }) = _ActiveRAGContextModel;

  factory ActiveRAGContextModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveRAGContextModelFromJson(json);
}
