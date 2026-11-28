// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_search_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentSearchRequestModel {

 String get query;
/// Create a copy of DocumentSearchRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSearchRequestModelCopyWith<DocumentSearchRequestModel> get copyWith => _$DocumentSearchRequestModelCopyWithImpl<DocumentSearchRequestModel>(this as DocumentSearchRequestModel, _$identity);

  /// Serializes this DocumentSearchRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSearchRequestModel&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'DocumentSearchRequestModel(query: $query)';
}


}

/// @nodoc
abstract mixin class $DocumentSearchRequestModelCopyWith<$Res>  {
  factory $DocumentSearchRequestModelCopyWith(DocumentSearchRequestModel value, $Res Function(DocumentSearchRequestModel) _then) = _$DocumentSearchRequestModelCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$DocumentSearchRequestModelCopyWithImpl<$Res>
    implements $DocumentSearchRequestModelCopyWith<$Res> {
  _$DocumentSearchRequestModelCopyWithImpl(this._self, this._then);

  final DocumentSearchRequestModel _self;
  final $Res Function(DocumentSearchRequestModel) _then;

/// Create a copy of DocumentSearchRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentSearchRequestModel].
extension DocumentSearchRequestModelPatterns on DocumentSearchRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSearchRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSearchRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSearchRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSearchRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSearchRequestModel() when $default != null:
return $default(_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query)  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchRequestModel():
return $default(_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchRequestModel() when $default != null:
return $default(_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSearchRequestModel implements DocumentSearchRequestModel {
  const _DocumentSearchRequestModel({required this.query});
  factory _DocumentSearchRequestModel.fromJson(Map<String, dynamic> json) => _$DocumentSearchRequestModelFromJson(json);

@override final  String query;

/// Create a copy of DocumentSearchRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSearchRequestModelCopyWith<_DocumentSearchRequestModel> get copyWith => __$DocumentSearchRequestModelCopyWithImpl<_DocumentSearchRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSearchRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSearchRequestModel&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'DocumentSearchRequestModel(query: $query)';
}


}

/// @nodoc
abstract mixin class _$DocumentSearchRequestModelCopyWith<$Res> implements $DocumentSearchRequestModelCopyWith<$Res> {
  factory _$DocumentSearchRequestModelCopyWith(_DocumentSearchRequestModel value, $Res Function(_DocumentSearchRequestModel) _then) = __$DocumentSearchRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String query
});




}
/// @nodoc
class __$DocumentSearchRequestModelCopyWithImpl<$Res>
    implements _$DocumentSearchRequestModelCopyWith<$Res> {
  __$DocumentSearchRequestModelCopyWithImpl(this._self, this._then);

  final _DocumentSearchRequestModel _self;
  final $Res Function(_DocumentSearchRequestModel) _then;

/// Create a copy of DocumentSearchRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_DocumentSearchRequestModel(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DocumentSearchResultModel {

@JsonKey(name: 'document_id') String get documentId; String get filename;@JsonKey(name: 'cloudinary_url') String? get cloudinaryUrl; double? get score;
/// Create a copy of DocumentSearchResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSearchResultModelCopyWith<DocumentSearchResultModel> get copyWith => _$DocumentSearchResultModelCopyWithImpl<DocumentSearchResultModel>(this as DocumentSearchResultModel, _$identity);

  /// Serializes this DocumentSearchResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSearchResultModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,filename,cloudinaryUrl,score);

@override
String toString() {
  return 'DocumentSearchResultModel(documentId: $documentId, filename: $filename, cloudinaryUrl: $cloudinaryUrl, score: $score)';
}


}

/// @nodoc
abstract mixin class $DocumentSearchResultModelCopyWith<$Res>  {
  factory $DocumentSearchResultModelCopyWith(DocumentSearchResultModel value, $Res Function(DocumentSearchResultModel) _then) = _$DocumentSearchResultModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String filename,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl, double? score
});




}
/// @nodoc
class _$DocumentSearchResultModelCopyWithImpl<$Res>
    implements $DocumentSearchResultModelCopyWith<$Res> {
  _$DocumentSearchResultModelCopyWithImpl(this._self, this._then);

  final DocumentSearchResultModel _self;
  final $Res Function(DocumentSearchResultModel) _then;

/// Create a copy of DocumentSearchResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? filename = null,Object? cloudinaryUrl = freezed,Object? score = freezed,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentSearchResultModel].
extension DocumentSearchResultModelPatterns on DocumentSearchResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSearchResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSearchResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSearchResultModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSearchResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String filename, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl,  double? score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSearchResultModel() when $default != null:
return $default(_that.documentId,_that.filename,_that.cloudinaryUrl,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String filename, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl,  double? score)  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchResultModel():
return $default(_that.documentId,_that.filename,_that.cloudinaryUrl,_that.score);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_id')  String documentId,  String filename, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl,  double? score)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchResultModel() when $default != null:
return $default(_that.documentId,_that.filename,_that.cloudinaryUrl,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSearchResultModel implements DocumentSearchResultModel {
  const _DocumentSearchResultModel({@JsonKey(name: 'document_id') required this.documentId, required this.filename, @JsonKey(name: 'cloudinary_url') this.cloudinaryUrl, this.score});
  factory _DocumentSearchResultModel.fromJson(Map<String, dynamic> json) => _$DocumentSearchResultModelFromJson(json);

@override@JsonKey(name: 'document_id') final  String documentId;
@override final  String filename;
@override@JsonKey(name: 'cloudinary_url') final  String? cloudinaryUrl;
@override final  double? score;

/// Create a copy of DocumentSearchResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSearchResultModelCopyWith<_DocumentSearchResultModel> get copyWith => __$DocumentSearchResultModelCopyWithImpl<_DocumentSearchResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSearchResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSearchResultModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,filename,cloudinaryUrl,score);

@override
String toString() {
  return 'DocumentSearchResultModel(documentId: $documentId, filename: $filename, cloudinaryUrl: $cloudinaryUrl, score: $score)';
}


}

/// @nodoc
abstract mixin class _$DocumentSearchResultModelCopyWith<$Res> implements $DocumentSearchResultModelCopyWith<$Res> {
  factory _$DocumentSearchResultModelCopyWith(_DocumentSearchResultModel value, $Res Function(_DocumentSearchResultModel) _then) = __$DocumentSearchResultModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String filename,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl, double? score
});




}
/// @nodoc
class __$DocumentSearchResultModelCopyWithImpl<$Res>
    implements _$DocumentSearchResultModelCopyWith<$Res> {
  __$DocumentSearchResultModelCopyWithImpl(this._self, this._then);

  final _DocumentSearchResultModel _self;
  final $Res Function(_DocumentSearchResultModel) _then;

/// Create a copy of DocumentSearchResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? filename = null,Object? cloudinaryUrl = freezed,Object? score = freezed,}) {
  return _then(_DocumentSearchResultModel(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$DocumentSearchResponseModel {

 String get query; List<DocumentSearchResultModel> get documents;
/// Create a copy of DocumentSearchResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSearchResponseModelCopyWith<DocumentSearchResponseModel> get copyWith => _$DocumentSearchResponseModelCopyWithImpl<DocumentSearchResponseModel>(this as DocumentSearchResponseModel, _$identity);

  /// Serializes this DocumentSearchResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSearchResponseModel&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'DocumentSearchResponseModel(query: $query, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $DocumentSearchResponseModelCopyWith<$Res>  {
  factory $DocumentSearchResponseModelCopyWith(DocumentSearchResponseModel value, $Res Function(DocumentSearchResponseModel) _then) = _$DocumentSearchResponseModelCopyWithImpl;
@useResult
$Res call({
 String query, List<DocumentSearchResultModel> documents
});




}
/// @nodoc
class _$DocumentSearchResponseModelCopyWithImpl<$Res>
    implements $DocumentSearchResponseModelCopyWith<$Res> {
  _$DocumentSearchResponseModelCopyWithImpl(this._self, this._then);

  final DocumentSearchResponseModel _self;
  final $Res Function(DocumentSearchResponseModel) _then;

/// Create a copy of DocumentSearchResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? documents = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentSearchResultModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentSearchResponseModel].
extension DocumentSearchResponseModelPatterns on DocumentSearchResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSearchResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSearchResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSearchResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSearchResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSearchResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<DocumentSearchResultModel> documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSearchResponseModel() when $default != null:
return $default(_that.query,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<DocumentSearchResultModel> documents)  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchResponseModel():
return $default(_that.query,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<DocumentSearchResultModel> documents)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSearchResponseModel() when $default != null:
return $default(_that.query,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSearchResponseModel implements DocumentSearchResponseModel {
  const _DocumentSearchResponseModel({required this.query, final  List<DocumentSearchResultModel> documents = const []}): _documents = documents;
  factory _DocumentSearchResponseModel.fromJson(Map<String, dynamic> json) => _$DocumentSearchResponseModelFromJson(json);

@override final  String query;
 final  List<DocumentSearchResultModel> _documents;
@override@JsonKey() List<DocumentSearchResultModel> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}


/// Create a copy of DocumentSearchResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSearchResponseModelCopyWith<_DocumentSearchResponseModel> get copyWith => __$DocumentSearchResponseModelCopyWithImpl<_DocumentSearchResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSearchResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSearchResponseModel&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._documents, _documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_documents));

@override
String toString() {
  return 'DocumentSearchResponseModel(query: $query, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$DocumentSearchResponseModelCopyWith<$Res> implements $DocumentSearchResponseModelCopyWith<$Res> {
  factory _$DocumentSearchResponseModelCopyWith(_DocumentSearchResponseModel value, $Res Function(_DocumentSearchResponseModel) _then) = __$DocumentSearchResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String query, List<DocumentSearchResultModel> documents
});




}
/// @nodoc
class __$DocumentSearchResponseModelCopyWithImpl<$Res>
    implements _$DocumentSearchResponseModelCopyWith<$Res> {
  __$DocumentSearchResponseModelCopyWithImpl(this._self, this._then);

  final _DocumentSearchResponseModel _self;
  final $Res Function(_DocumentSearchResponseModel) _then;

/// Create a copy of DocumentSearchResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? documents = null,}) {
  return _then(_DocumentSearchResponseModel(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentSearchResultModel>,
  ));
}


}

// dart format on
