// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardMetricsModel {

@JsonKey(readValue: _readCount) int get synthesizedDocsCount;@JsonKey(readValue: _readHours) double get audioNotesHours;@JsonKey(readValue: _readConfidence) double get confidencePercentage;
/// Create a copy of DashboardMetricsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardMetricsModelCopyWith<DashboardMetricsModel> get copyWith => _$DashboardMetricsModelCopyWithImpl<DashboardMetricsModel>(this as DashboardMetricsModel, _$identity);

  /// Serializes this DashboardMetricsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardMetricsModel&&(identical(other.synthesizedDocsCount, synthesizedDocsCount) || other.synthesizedDocsCount == synthesizedDocsCount)&&(identical(other.audioNotesHours, audioNotesHours) || other.audioNotesHours == audioNotesHours)&&(identical(other.confidencePercentage, confidencePercentage) || other.confidencePercentage == confidencePercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,synthesizedDocsCount,audioNotesHours,confidencePercentage);

@override
String toString() {
  return 'DashboardMetricsModel(synthesizedDocsCount: $synthesizedDocsCount, audioNotesHours: $audioNotesHours, confidencePercentage: $confidencePercentage)';
}


}

/// @nodoc
abstract mixin class $DashboardMetricsModelCopyWith<$Res>  {
  factory $DashboardMetricsModelCopyWith(DashboardMetricsModel value, $Res Function(DashboardMetricsModel) _then) = _$DashboardMetricsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readCount) int synthesizedDocsCount,@JsonKey(readValue: _readHours) double audioNotesHours,@JsonKey(readValue: _readConfidence) double confidencePercentage
});




}
/// @nodoc
class _$DashboardMetricsModelCopyWithImpl<$Res>
    implements $DashboardMetricsModelCopyWith<$Res> {
  _$DashboardMetricsModelCopyWithImpl(this._self, this._then);

  final DashboardMetricsModel _self;
  final $Res Function(DashboardMetricsModel) _then;

/// Create a copy of DashboardMetricsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? synthesizedDocsCount = null,Object? audioNotesHours = null,Object? confidencePercentage = null,}) {
  return _then(_self.copyWith(
synthesizedDocsCount: null == synthesizedDocsCount ? _self.synthesizedDocsCount : synthesizedDocsCount // ignore: cast_nullable_to_non_nullable
as int,audioNotesHours: null == audioNotesHours ? _self.audioNotesHours : audioNotesHours // ignore: cast_nullable_to_non_nullable
as double,confidencePercentage: null == confidencePercentage ? _self.confidencePercentage : confidencePercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardMetricsModel].
extension DashboardMetricsModelPatterns on DashboardMetricsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardMetricsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardMetricsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardMetricsModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardMetricsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardMetricsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardMetricsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCount)  int synthesizedDocsCount, @JsonKey(readValue: _readHours)  double audioNotesHours, @JsonKey(readValue: _readConfidence)  double confidencePercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardMetricsModel() when $default != null:
return $default(_that.synthesizedDocsCount,_that.audioNotesHours,_that.confidencePercentage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCount)  int synthesizedDocsCount, @JsonKey(readValue: _readHours)  double audioNotesHours, @JsonKey(readValue: _readConfidence)  double confidencePercentage)  $default,) {final _that = this;
switch (_that) {
case _DashboardMetricsModel():
return $default(_that.synthesizedDocsCount,_that.audioNotesHours,_that.confidencePercentage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readCount)  int synthesizedDocsCount, @JsonKey(readValue: _readHours)  double audioNotesHours, @JsonKey(readValue: _readConfidence)  double confidencePercentage)?  $default,) {final _that = this;
switch (_that) {
case _DashboardMetricsModel() when $default != null:
return $default(_that.synthesizedDocsCount,_that.audioNotesHours,_that.confidencePercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardMetricsModel implements DashboardMetricsModel {
  const _DashboardMetricsModel({@JsonKey(readValue: _readCount) this.synthesizedDocsCount = 24, @JsonKey(readValue: _readHours) this.audioNotesHours = 4.8, @JsonKey(readValue: _readConfidence) this.confidencePercentage = 99.4});
  factory _DashboardMetricsModel.fromJson(Map<String, dynamic> json) => _$DashboardMetricsModelFromJson(json);

@override@JsonKey(readValue: _readCount) final  int synthesizedDocsCount;
@override@JsonKey(readValue: _readHours) final  double audioNotesHours;
@override@JsonKey(readValue: _readConfidence) final  double confidencePercentage;

/// Create a copy of DashboardMetricsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardMetricsModelCopyWith<_DashboardMetricsModel> get copyWith => __$DashboardMetricsModelCopyWithImpl<_DashboardMetricsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardMetricsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardMetricsModel&&(identical(other.synthesizedDocsCount, synthesizedDocsCount) || other.synthesizedDocsCount == synthesizedDocsCount)&&(identical(other.audioNotesHours, audioNotesHours) || other.audioNotesHours == audioNotesHours)&&(identical(other.confidencePercentage, confidencePercentage) || other.confidencePercentage == confidencePercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,synthesizedDocsCount,audioNotesHours,confidencePercentage);

@override
String toString() {
  return 'DashboardMetricsModel(synthesizedDocsCount: $synthesizedDocsCount, audioNotesHours: $audioNotesHours, confidencePercentage: $confidencePercentage)';
}


}

/// @nodoc
abstract mixin class _$DashboardMetricsModelCopyWith<$Res> implements $DashboardMetricsModelCopyWith<$Res> {
  factory _$DashboardMetricsModelCopyWith(_DashboardMetricsModel value, $Res Function(_DashboardMetricsModel) _then) = __$DashboardMetricsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readCount) int synthesizedDocsCount,@JsonKey(readValue: _readHours) double audioNotesHours,@JsonKey(readValue: _readConfidence) double confidencePercentage
});




}
/// @nodoc
class __$DashboardMetricsModelCopyWithImpl<$Res>
    implements _$DashboardMetricsModelCopyWith<$Res> {
  __$DashboardMetricsModelCopyWithImpl(this._self, this._then);

  final _DashboardMetricsModel _self;
  final $Res Function(_DashboardMetricsModel) _then;

/// Create a copy of DashboardMetricsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? synthesizedDocsCount = null,Object? audioNotesHours = null,Object? confidencePercentage = null,}) {
  return _then(_DashboardMetricsModel(
synthesizedDocsCount: null == synthesizedDocsCount ? _self.synthesizedDocsCount : synthesizedDocsCount // ignore: cast_nullable_to_non_nullable
as int,audioNotesHours: null == audioNotesHours ? _self.audioNotesHours : audioNotesHours // ignore: cast_nullable_to_non_nullable
as double,confidencePercentage: null == confidencePercentage ? _self.confidencePercentage : confidencePercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
