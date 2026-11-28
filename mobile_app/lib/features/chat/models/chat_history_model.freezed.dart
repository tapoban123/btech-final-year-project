// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SynthesisPointModel {

 int get number; String get title; String get description; String? get highlight;
/// Create a copy of SynthesisPointModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SynthesisPointModelCopyWith<SynthesisPointModel> get copyWith => _$SynthesisPointModelCopyWithImpl<SynthesisPointModel>(this as SynthesisPointModel, _$identity);

  /// Serializes this SynthesisPointModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SynthesisPointModel&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.highlight, highlight) || other.highlight == highlight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,description,highlight);

@override
String toString() {
  return 'SynthesisPointModel(number: $number, title: $title, description: $description, highlight: $highlight)';
}


}

/// @nodoc
abstract mixin class $SynthesisPointModelCopyWith<$Res>  {
  factory $SynthesisPointModelCopyWith(SynthesisPointModel value, $Res Function(SynthesisPointModel) _then) = _$SynthesisPointModelCopyWithImpl;
@useResult
$Res call({
 int number, String title, String description, String? highlight
});




}
/// @nodoc
class _$SynthesisPointModelCopyWithImpl<$Res>
    implements $SynthesisPointModelCopyWith<$Res> {
  _$SynthesisPointModelCopyWithImpl(this._self, this._then);

  final SynthesisPointModel _self;
  final $Res Function(SynthesisPointModel) _then;

/// Create a copy of SynthesisPointModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? title = null,Object? description = null,Object? highlight = freezed,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,highlight: freezed == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SynthesisPointModel].
extension SynthesisPointModelPatterns on SynthesisPointModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SynthesisPointModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SynthesisPointModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SynthesisPointModel value)  $default,){
final _that = this;
switch (_that) {
case _SynthesisPointModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SynthesisPointModel value)?  $default,){
final _that = this;
switch (_that) {
case _SynthesisPointModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String title,  String description,  String? highlight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SynthesisPointModel() when $default != null:
return $default(_that.number,_that.title,_that.description,_that.highlight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String title,  String description,  String? highlight)  $default,) {final _that = this;
switch (_that) {
case _SynthesisPointModel():
return $default(_that.number,_that.title,_that.description,_that.highlight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String title,  String description,  String? highlight)?  $default,) {final _that = this;
switch (_that) {
case _SynthesisPointModel() when $default != null:
return $default(_that.number,_that.title,_that.description,_that.highlight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SynthesisPointModel implements SynthesisPointModel {
  const _SynthesisPointModel({this.number = 1, this.title = '', this.description = '', this.highlight});
  factory _SynthesisPointModel.fromJson(Map<String, dynamic> json) => _$SynthesisPointModelFromJson(json);

@override@JsonKey() final  int number;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  String? highlight;

/// Create a copy of SynthesisPointModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SynthesisPointModelCopyWith<_SynthesisPointModel> get copyWith => __$SynthesisPointModelCopyWithImpl<_SynthesisPointModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SynthesisPointModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SynthesisPointModel&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.highlight, highlight) || other.highlight == highlight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,description,highlight);

@override
String toString() {
  return 'SynthesisPointModel(number: $number, title: $title, description: $description, highlight: $highlight)';
}


}

/// @nodoc
abstract mixin class _$SynthesisPointModelCopyWith<$Res> implements $SynthesisPointModelCopyWith<$Res> {
  factory _$SynthesisPointModelCopyWith(_SynthesisPointModel value, $Res Function(_SynthesisPointModel) _then) = __$SynthesisPointModelCopyWithImpl;
@override @useResult
$Res call({
 int number, String title, String description, String? highlight
});




}
/// @nodoc
class __$SynthesisPointModelCopyWithImpl<$Res>
    implements _$SynthesisPointModelCopyWith<$Res> {
  __$SynthesisPointModelCopyWithImpl(this._self, this._then);

  final _SynthesisPointModel _self;
  final $Res Function(_SynthesisPointModel) _then;

/// Create a copy of SynthesisPointModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? title = null,Object? description = null,Object? highlight = freezed,}) {
  return _then(_SynthesisPointModel(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,highlight: freezed == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatCitationModel {

 String get title; String get reference; String get type;@JsonKey(name: 'cloudinary_url') String? get cloudinaryUrl;
/// Create a copy of ChatCitationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCitationModelCopyWith<ChatCitationModel> get copyWith => _$ChatCitationModelCopyWithImpl<ChatCitationModel>(this as ChatCitationModel, _$identity);

  /// Serializes this ChatCitationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatCitationModel&&(identical(other.title, title) || other.title == title)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.type, type) || other.type == type)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,reference,type,cloudinaryUrl);

@override
String toString() {
  return 'ChatCitationModel(title: $title, reference: $reference, type: $type, cloudinaryUrl: $cloudinaryUrl)';
}


}

/// @nodoc
abstract mixin class $ChatCitationModelCopyWith<$Res>  {
  factory $ChatCitationModelCopyWith(ChatCitationModel value, $Res Function(ChatCitationModel) _then) = _$ChatCitationModelCopyWithImpl;
@useResult
$Res call({
 String title, String reference, String type,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl
});




}
/// @nodoc
class _$ChatCitationModelCopyWithImpl<$Res>
    implements $ChatCitationModelCopyWith<$Res> {
  _$ChatCitationModelCopyWithImpl(this._self, this._then);

  final ChatCitationModel _self;
  final $Res Function(ChatCitationModel) _then;

/// Create a copy of ChatCitationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? reference = null,Object? type = null,Object? cloudinaryUrl = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatCitationModel].
extension ChatCitationModelPatterns on ChatCitationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatCitationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatCitationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatCitationModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatCitationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatCitationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatCitationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String reference,  String type, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatCitationModel() when $default != null:
return $default(_that.title,_that.reference,_that.type,_that.cloudinaryUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String reference,  String type, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatCitationModel():
return $default(_that.title,_that.reference,_that.type,_that.cloudinaryUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String reference,  String type, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatCitationModel() when $default != null:
return $default(_that.title,_that.reference,_that.type,_that.cloudinaryUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatCitationModel implements ChatCitationModel {
  const _ChatCitationModel({this.title = '', this.reference = '', this.type = 'pdf', @JsonKey(name: 'cloudinary_url') this.cloudinaryUrl});
  factory _ChatCitationModel.fromJson(Map<String, dynamic> json) => _$ChatCitationModelFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  String reference;
@override@JsonKey() final  String type;
@override@JsonKey(name: 'cloudinary_url') final  String? cloudinaryUrl;

/// Create a copy of ChatCitationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCitationModelCopyWith<_ChatCitationModel> get copyWith => __$ChatCitationModelCopyWithImpl<_ChatCitationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatCitationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatCitationModel&&(identical(other.title, title) || other.title == title)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.type, type) || other.type == type)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,reference,type,cloudinaryUrl);

@override
String toString() {
  return 'ChatCitationModel(title: $title, reference: $reference, type: $type, cloudinaryUrl: $cloudinaryUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatCitationModelCopyWith<$Res> implements $ChatCitationModelCopyWith<$Res> {
  factory _$ChatCitationModelCopyWith(_ChatCitationModel value, $Res Function(_ChatCitationModel) _then) = __$ChatCitationModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String reference, String type,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl
});




}
/// @nodoc
class __$ChatCitationModelCopyWithImpl<$Res>
    implements _$ChatCitationModelCopyWith<$Res> {
  __$ChatCitationModelCopyWithImpl(this._self, this._then);

  final _ChatCitationModel _self;
  final $Res Function(_ChatCitationModel) _then;

/// Create a copy of ChatCitationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? reference = null,Object? type = null,Object? cloudinaryUrl = freezed,}) {
  return _then(_ChatCitationModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatHistoryItemModel {

 String get id; String get sender; String get content; String get timestamp; List<SynthesisPointModel> get points; List<ChatCitationModel> get citations;
/// Create a copy of ChatHistoryItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatHistoryItemModelCopyWith<ChatHistoryItemModel> get copyWith => _$ChatHistoryItemModelCopyWithImpl<ChatHistoryItemModel>(this as ChatHistoryItemModel, _$identity);

  /// Serializes this ChatHistoryItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatHistoryItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.points, points)&&const DeepCollectionEquality().equals(other.citations, citations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,content,timestamp,const DeepCollectionEquality().hash(points),const DeepCollectionEquality().hash(citations));

@override
String toString() {
  return 'ChatHistoryItemModel(id: $id, sender: $sender, content: $content, timestamp: $timestamp, points: $points, citations: $citations)';
}


}

/// @nodoc
abstract mixin class $ChatHistoryItemModelCopyWith<$Res>  {
  factory $ChatHistoryItemModelCopyWith(ChatHistoryItemModel value, $Res Function(ChatHistoryItemModel) _then) = _$ChatHistoryItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String sender, String content, String timestamp, List<SynthesisPointModel> points, List<ChatCitationModel> citations
});




}
/// @nodoc
class _$ChatHistoryItemModelCopyWithImpl<$Res>
    implements $ChatHistoryItemModelCopyWith<$Res> {
  _$ChatHistoryItemModelCopyWithImpl(this._self, this._then);

  final ChatHistoryItemModel _self;
  final $Res Function(ChatHistoryItemModel) _then;

/// Create a copy of ChatHistoryItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sender = null,Object? content = null,Object? timestamp = null,Object? points = null,Object? citations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<SynthesisPointModel>,citations: null == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<ChatCitationModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatHistoryItemModel].
extension ChatHistoryItemModelPatterns on ChatHistoryItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatHistoryItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatHistoryItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatHistoryItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatHistoryItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatHistoryItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatHistoryItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sender,  String content,  String timestamp,  List<SynthesisPointModel> points,  List<ChatCitationModel> citations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatHistoryItemModel() when $default != null:
return $default(_that.id,_that.sender,_that.content,_that.timestamp,_that.points,_that.citations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sender,  String content,  String timestamp,  List<SynthesisPointModel> points,  List<ChatCitationModel> citations)  $default,) {final _that = this;
switch (_that) {
case _ChatHistoryItemModel():
return $default(_that.id,_that.sender,_that.content,_that.timestamp,_that.points,_that.citations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sender,  String content,  String timestamp,  List<SynthesisPointModel> points,  List<ChatCitationModel> citations)?  $default,) {final _that = this;
switch (_that) {
case _ChatHistoryItemModel() when $default != null:
return $default(_that.id,_that.sender,_that.content,_that.timestamp,_that.points,_that.citations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatHistoryItemModel implements ChatHistoryItemModel {
  const _ChatHistoryItemModel({required this.id, this.sender = 'user', this.content = '', this.timestamp = '', final  List<SynthesisPointModel> points = const [], final  List<ChatCitationModel> citations = const []}): _points = points,_citations = citations;
  factory _ChatHistoryItemModel.fromJson(Map<String, dynamic> json) => _$ChatHistoryItemModelFromJson(json);

@override final  String id;
@override@JsonKey() final  String sender;
@override@JsonKey() final  String content;
@override@JsonKey() final  String timestamp;
 final  List<SynthesisPointModel> _points;
@override@JsonKey() List<SynthesisPointModel> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

 final  List<ChatCitationModel> _citations;
@override@JsonKey() List<ChatCitationModel> get citations {
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citations);
}


/// Create a copy of ChatHistoryItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatHistoryItemModelCopyWith<_ChatHistoryItemModel> get copyWith => __$ChatHistoryItemModelCopyWithImpl<_ChatHistoryItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatHistoryItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatHistoryItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._points, _points)&&const DeepCollectionEquality().equals(other._citations, _citations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,content,timestamp,const DeepCollectionEquality().hash(_points),const DeepCollectionEquality().hash(_citations));

@override
String toString() {
  return 'ChatHistoryItemModel(id: $id, sender: $sender, content: $content, timestamp: $timestamp, points: $points, citations: $citations)';
}


}

/// @nodoc
abstract mixin class _$ChatHistoryItemModelCopyWith<$Res> implements $ChatHistoryItemModelCopyWith<$Res> {
  factory _$ChatHistoryItemModelCopyWith(_ChatHistoryItemModel value, $Res Function(_ChatHistoryItemModel) _then) = __$ChatHistoryItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String sender, String content, String timestamp, List<SynthesisPointModel> points, List<ChatCitationModel> citations
});




}
/// @nodoc
class __$ChatHistoryItemModelCopyWithImpl<$Res>
    implements _$ChatHistoryItemModelCopyWith<$Res> {
  __$ChatHistoryItemModelCopyWithImpl(this._self, this._then);

  final _ChatHistoryItemModel _self;
  final $Res Function(_ChatHistoryItemModel) _then;

/// Create a copy of ChatHistoryItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sender = null,Object? content = null,Object? timestamp = null,Object? points = null,Object? citations = null,}) {
  return _then(_ChatHistoryItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<SynthesisPointModel>,citations: null == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<ChatCitationModel>,
  ));
}


}


/// @nodoc
mixin _$ActiveRAGContextModel {

 String get id; String get title; String get type;
/// Create a copy of ActiveRAGContextModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveRAGContextModelCopyWith<ActiveRAGContextModel> get copyWith => _$ActiveRAGContextModelCopyWithImpl<ActiveRAGContextModel>(this as ActiveRAGContextModel, _$identity);

  /// Serializes this ActiveRAGContextModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveRAGContextModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type);

@override
String toString() {
  return 'ActiveRAGContextModel(id: $id, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class $ActiveRAGContextModelCopyWith<$Res>  {
  factory $ActiveRAGContextModelCopyWith(ActiveRAGContextModel value, $Res Function(ActiveRAGContextModel) _then) = _$ActiveRAGContextModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String type
});




}
/// @nodoc
class _$ActiveRAGContextModelCopyWithImpl<$Res>
    implements $ActiveRAGContextModelCopyWith<$Res> {
  _$ActiveRAGContextModelCopyWithImpl(this._self, this._then);

  final ActiveRAGContextModel _self;
  final $Res Function(ActiveRAGContextModel) _then;

/// Create a copy of ActiveRAGContextModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveRAGContextModel].
extension ActiveRAGContextModelPatterns on ActiveRAGContextModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveRAGContextModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveRAGContextModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveRAGContextModel value)  $default,){
final _that = this;
switch (_that) {
case _ActiveRAGContextModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveRAGContextModel value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveRAGContextModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveRAGContextModel() when $default != null:
return $default(_that.id,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String type)  $default,) {final _that = this;
switch (_that) {
case _ActiveRAGContextModel():
return $default(_that.id,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String type)?  $default,) {final _that = this;
switch (_that) {
case _ActiveRAGContextModel() when $default != null:
return $default(_that.id,_that.title,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActiveRAGContextModel implements ActiveRAGContextModel {
  const _ActiveRAGContextModel({required this.id, required this.title, this.type = 'pdf'});
  factory _ActiveRAGContextModel.fromJson(Map<String, dynamic> json) => _$ActiveRAGContextModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String type;

/// Create a copy of ActiveRAGContextModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveRAGContextModelCopyWith<_ActiveRAGContextModel> get copyWith => __$ActiveRAGContextModelCopyWithImpl<_ActiveRAGContextModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActiveRAGContextModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveRAGContextModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type);

@override
String toString() {
  return 'ActiveRAGContextModel(id: $id, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ActiveRAGContextModelCopyWith<$Res> implements $ActiveRAGContextModelCopyWith<$Res> {
  factory _$ActiveRAGContextModelCopyWith(_ActiveRAGContextModel value, $Res Function(_ActiveRAGContextModel) _then) = __$ActiveRAGContextModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String type
});




}
/// @nodoc
class __$ActiveRAGContextModelCopyWithImpl<$Res>
    implements _$ActiveRAGContextModelCopyWith<$Res> {
  __$ActiveRAGContextModelCopyWithImpl(this._self, this._then);

  final _ActiveRAGContextModel _self;
  final $Res Function(_ActiveRAGContextModel) _then;

/// Create a copy of ActiveRAGContextModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? type = null,}) {
  return _then(_ActiveRAGContextModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
