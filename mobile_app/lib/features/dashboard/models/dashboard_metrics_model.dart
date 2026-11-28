import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics_model.freezed.dart';
part 'dashboard_metrics_model.g.dart';

Object? _readCount(Map json, String key) =>
    json['synthesized_docs_count'] ?? json['synthesizedDocsCount'] ?? 24;

Object? _readHours(Map json, String key) =>
    (json['audio_notes_hours'] ?? json['audioNotesHours'] ?? 4.8);

Object? _readConfidence(Map json, String key) =>
    (json['confidence_percentage'] ?? json['confidencePercentage'] ?? 99.4);

@freezed
abstract class DashboardMetricsModel with _$DashboardMetricsModel {
  const factory DashboardMetricsModel({
    @JsonKey(readValue: _readCount) @Default(24) int synthesizedDocsCount,
    @JsonKey(readValue: _readHours) @Default(4.8) double audioNotesHours,
    @JsonKey(readValue: _readConfidence) @Default(99.4) double confidencePercentage,
  }) = _DashboardMetricsModel;

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsModelFromJson(json);
}
