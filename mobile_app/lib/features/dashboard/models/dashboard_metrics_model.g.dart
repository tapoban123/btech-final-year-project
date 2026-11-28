// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardMetricsModel _$DashboardMetricsModelFromJson(
  Map<String, dynamic> json,
) => _DashboardMetricsModel(
  synthesizedDocsCount:
      (_readCount(json, 'synthesizedDocsCount') as num?)?.toInt() ?? 24,
  audioNotesHours:
      (_readHours(json, 'audioNotesHours') as num?)?.toDouble() ?? 4.8,
  confidencePercentage:
      (_readConfidence(json, 'confidencePercentage') as num?)?.toDouble() ??
      99.4,
);

Map<String, dynamic> _$DashboardMetricsModelToJson(
  _DashboardMetricsModel instance,
) => <String, dynamic>{
  'synthesizedDocsCount': instance.synthesizedDocsCount,
  'audioNotesHours': instance.audioNotesHours,
  'confidencePercentage': instance.confidencePercentage,
};
