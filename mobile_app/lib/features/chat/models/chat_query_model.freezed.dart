// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_query_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentQueryRequestModel {

 String get query;
/// Create a copy of DocumentQueryRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentQueryRequestModelCopyWith<DocumentQueryRequestModel> get copyWith => _$DocumentQueryRequestModelCopyWithImpl<DocumentQueryRequestModel>(this as DocumentQueryRequestModel, _$identity);

  /// Serializes this DocumentQueryRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentQueryRequestModel&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'DocumentQueryRequestModel(query: $query)';
}


}

/// @nodoc
abstract mixin class $DocumentQueryRequestModelCopyWith<$Res>  {
  factory $DocumentQueryRequestModelCopyWith(DocumentQueryRequestModel value, $Res Function(DocumentQueryRequestModel) _then) = _$DocumentQueryRequestModelCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$DocumentQueryRequestModelCopyWithImpl<$Res>
    implements $DocumentQueryRequestModelCopyWith<$Res> {
  _$DocumentQueryRequestModelCopyWithImpl(this._self, this._then);

  final DocumentQueryRequestModel _self;
  final $Res Function(DocumentQueryRequestModel) _then;

/// Create a copy of DocumentQueryRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentQueryRequestModel].
extension DocumentQueryRequestModelPatterns on DocumentQueryRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentQueryRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentQueryRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentQueryRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentQueryRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentQueryRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentQueryRequestModel() when $default != null:
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
case _DocumentQueryRequestModel() when $default != null:
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
case _DocumentQueryRequestModel():
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
case _DocumentQueryRequestModel() when $default != null:
return $default(_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentQueryRequestModel implements DocumentQueryRequestModel {
  const _DocumentQueryRequestModel({required this.query});
  factory _DocumentQueryRequestModel.fromJson(Map<String, dynamic> json) => _$DocumentQueryRequestModelFromJson(json);

@override final  String query;

/// Create a copy of DocumentQueryRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentQueryRequestModelCopyWith<_DocumentQueryRequestModel> get copyWith => __$DocumentQueryRequestModelCopyWithImpl<_DocumentQueryRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentQueryRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentQueryRequestModel&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'DocumentQueryRequestModel(query: $query)';
}


}

/// @nodoc
abstract mixin class _$DocumentQueryRequestModelCopyWith<$Res> implements $DocumentQueryRequestModelCopyWith<$Res> {
  factory _$DocumentQueryRequestModelCopyWith(_DocumentQueryRequestModel value, $Res Function(_DocumentQueryRequestModel) _then) = __$DocumentQueryRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String query
});




}
/// @nodoc
class __$DocumentQueryRequestModelCopyWithImpl<$Res>
    implements _$DocumentQueryRequestModelCopyWith<$Res> {
  __$DocumentQueryRequestModelCopyWithImpl(this._self, this._then);

  final _DocumentQueryRequestModel _self;
  final $Res Function(_DocumentQueryRequestModel) _then;

/// Create a copy of DocumentQueryRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_DocumentQueryRequestModel(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$QueryCitationModel {

@JsonKey(name: 'document_id') String get documentId;@JsonKey(name: 'document_name') String get documentName; int get page; String? get snippet;@JsonKey(name: 'cloudinary_url') String? get cloudinaryUrl;@JsonKey(name: 'mime_type') String? get mimeType;
/// Create a copy of QueryCitationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryCitationModelCopyWith<QueryCitationModel> get copyWith => _$QueryCitationModelCopyWithImpl<QueryCitationModel>(this as QueryCitationModel, _$identity);

  /// Serializes this QueryCitationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryCitationModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.documentName, documentName) || other.documentName == documentName)&&(identical(other.page, page) || other.page == page)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,documentName,page,snippet,cloudinaryUrl,mimeType);

@override
String toString() {
  return 'QueryCitationModel(documentId: $documentId, documentName: $documentName, page: $page, snippet: $snippet, cloudinaryUrl: $cloudinaryUrl, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class $QueryCitationModelCopyWith<$Res>  {
  factory $QueryCitationModelCopyWith(QueryCitationModel value, $Res Function(QueryCitationModel) _then) = _$QueryCitationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'document_name') String documentName, int page, String? snippet,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,@JsonKey(name: 'mime_type') String? mimeType
});




}
/// @nodoc
class _$QueryCitationModelCopyWithImpl<$Res>
    implements $QueryCitationModelCopyWith<$Res> {
  _$QueryCitationModelCopyWithImpl(this._self, this._then);

  final QueryCitationModel _self;
  final $Res Function(QueryCitationModel) _then;

/// Create a copy of QueryCitationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? documentName = null,Object? page = null,Object? snippet = freezed,Object? cloudinaryUrl = freezed,Object? mimeType = freezed,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentName: null == documentName ? _self.documentName : documentName // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QueryCitationModel].
extension QueryCitationModelPatterns on QueryCitationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueryCitationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueryCitationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueryCitationModel value)  $default,){
final _that = this;
switch (_that) {
case _QueryCitationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueryCitationModel value)?  $default,){
final _that = this;
switch (_that) {
case _QueryCitationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'document_name')  String documentName,  int page,  String? snippet, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueryCitationModel() when $default != null:
return $default(_that.documentId,_that.documentName,_that.page,_that.snippet,_that.cloudinaryUrl,_that.mimeType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'document_name')  String documentName,  int page,  String? snippet, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)  $default,) {final _that = this;
switch (_that) {
case _QueryCitationModel():
return $default(_that.documentId,_that.documentName,_that.page,_that.snippet,_that.cloudinaryUrl,_that.mimeType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'document_name')  String documentName,  int page,  String? snippet, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)?  $default,) {final _that = this;
switch (_that) {
case _QueryCitationModel() when $default != null:
return $default(_that.documentId,_that.documentName,_that.page,_that.snippet,_that.cloudinaryUrl,_that.mimeType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QueryCitationModel implements QueryCitationModel {
  const _QueryCitationModel({@JsonKey(name: 'document_id') this.documentId = '', @JsonKey(name: 'document_name') this.documentName = '', this.page = 1, this.snippet, @JsonKey(name: 'cloudinary_url') this.cloudinaryUrl, @JsonKey(name: 'mime_type') this.mimeType});
  factory _QueryCitationModel.fromJson(Map<String, dynamic> json) => _$QueryCitationModelFromJson(json);

@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey(name: 'document_name') final  String documentName;
@override@JsonKey() final  int page;
@override final  String? snippet;
@override@JsonKey(name: 'cloudinary_url') final  String? cloudinaryUrl;
@override@JsonKey(name: 'mime_type') final  String? mimeType;

/// Create a copy of QueryCitationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueryCitationModelCopyWith<_QueryCitationModel> get copyWith => __$QueryCitationModelCopyWithImpl<_QueryCitationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueryCitationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueryCitationModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.documentName, documentName) || other.documentName == documentName)&&(identical(other.page, page) || other.page == page)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,documentName,page,snippet,cloudinaryUrl,mimeType);

@override
String toString() {
  return 'QueryCitationModel(documentId: $documentId, documentName: $documentName, page: $page, snippet: $snippet, cloudinaryUrl: $cloudinaryUrl, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class _$QueryCitationModelCopyWith<$Res> implements $QueryCitationModelCopyWith<$Res> {
  factory _$QueryCitationModelCopyWith(_QueryCitationModel value, $Res Function(_QueryCitationModel) _then) = __$QueryCitationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'document_name') String documentName, int page, String? snippet,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,@JsonKey(name: 'mime_type') String? mimeType
});




}
/// @nodoc
class __$QueryCitationModelCopyWithImpl<$Res>
    implements _$QueryCitationModelCopyWith<$Res> {
  __$QueryCitationModelCopyWithImpl(this._self, this._then);

  final _QueryCitationModel _self;
  final $Res Function(_QueryCitationModel) _then;

/// Create a copy of QueryCitationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? documentName = null,Object? page = null,Object? snippet = freezed,Object? cloudinaryUrl = freezed,Object? mimeType = freezed,}) {
  return _then(_QueryCitationModel(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentName: null == documentName ? _self.documentName : documentName // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MultiDocumentQueryResponseModel {

 String get answer; List<QueryCitationModel> get sources; List<DocumentMetadataModel> get documents;
/// Create a copy of MultiDocumentQueryResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiDocumentQueryResponseModelCopyWith<MultiDocumentQueryResponseModel> get copyWith => _$MultiDocumentQueryResponseModelCopyWithImpl<MultiDocumentQueryResponseModel>(this as MultiDocumentQueryResponseModel, _$identity);

  /// Serializes this MultiDocumentQueryResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiDocumentQueryResponseModel&&(identical(other.answer, answer) || other.answer == answer)&&const DeepCollectionEquality().equals(other.sources, sources)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,answer,const DeepCollectionEquality().hash(sources),const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'MultiDocumentQueryResponseModel(answer: $answer, sources: $sources, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $MultiDocumentQueryResponseModelCopyWith<$Res>  {
  factory $MultiDocumentQueryResponseModelCopyWith(MultiDocumentQueryResponseModel value, $Res Function(MultiDocumentQueryResponseModel) _then) = _$MultiDocumentQueryResponseModelCopyWithImpl;
@useResult
$Res call({
 String answer, List<QueryCitationModel> sources, List<DocumentMetadataModel> documents
});




}
/// @nodoc
class _$MultiDocumentQueryResponseModelCopyWithImpl<$Res>
    implements $MultiDocumentQueryResponseModelCopyWith<$Res> {
  _$MultiDocumentQueryResponseModelCopyWithImpl(this._self, this._then);

  final MultiDocumentQueryResponseModel _self;
  final $Res Function(MultiDocumentQueryResponseModel) _then;

/// Create a copy of MultiDocumentQueryResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answer = null,Object? sources = null,Object? documents = null,}) {
  return _then(_self.copyWith(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<QueryCitationModel>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentMetadataModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MultiDocumentQueryResponseModel].
extension MultiDocumentQueryResponseModelPatterns on MultiDocumentQueryResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultiDocumentQueryResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultiDocumentQueryResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultiDocumentQueryResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String answer,  List<QueryCitationModel> sources,  List<DocumentMetadataModel> documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel() when $default != null:
return $default(_that.answer,_that.sources,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String answer,  List<QueryCitationModel> sources,  List<DocumentMetadataModel> documents)  $default,) {final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel():
return $default(_that.answer,_that.sources,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String answer,  List<QueryCitationModel> sources,  List<DocumentMetadataModel> documents)?  $default,) {final _that = this;
switch (_that) {
case _MultiDocumentQueryResponseModel() when $default != null:
return $default(_that.answer,_that.sources,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MultiDocumentQueryResponseModel implements MultiDocumentQueryResponseModel {
  const _MultiDocumentQueryResponseModel({this.answer = '', final  List<QueryCitationModel> sources = const [], final  List<DocumentMetadataModel> documents = const []}): _sources = sources,_documents = documents;
  factory _MultiDocumentQueryResponseModel.fromJson(Map<String, dynamic> json) => _$MultiDocumentQueryResponseModelFromJson(json);

@override@JsonKey() final  String answer;
 final  List<QueryCitationModel> _sources;
@override@JsonKey() List<QueryCitationModel> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

 final  List<DocumentMetadataModel> _documents;
@override@JsonKey() List<DocumentMetadataModel> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}


/// Create a copy of MultiDocumentQueryResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultiDocumentQueryResponseModelCopyWith<_MultiDocumentQueryResponseModel> get copyWith => __$MultiDocumentQueryResponseModelCopyWithImpl<_MultiDocumentQueryResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultiDocumentQueryResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultiDocumentQueryResponseModel&&(identical(other.answer, answer) || other.answer == answer)&&const DeepCollectionEquality().equals(other._sources, _sources)&&const DeepCollectionEquality().equals(other._documents, _documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,answer,const DeepCollectionEquality().hash(_sources),const DeepCollectionEquality().hash(_documents));

@override
String toString() {
  return 'MultiDocumentQueryResponseModel(answer: $answer, sources: $sources, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$MultiDocumentQueryResponseModelCopyWith<$Res> implements $MultiDocumentQueryResponseModelCopyWith<$Res> {
  factory _$MultiDocumentQueryResponseModelCopyWith(_MultiDocumentQueryResponseModel value, $Res Function(_MultiDocumentQueryResponseModel) _then) = __$MultiDocumentQueryResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String answer, List<QueryCitationModel> sources, List<DocumentMetadataModel> documents
});




}
/// @nodoc
class __$MultiDocumentQueryResponseModelCopyWithImpl<$Res>
    implements _$MultiDocumentQueryResponseModelCopyWith<$Res> {
  __$MultiDocumentQueryResponseModelCopyWithImpl(this._self, this._then);

  final _MultiDocumentQueryResponseModel _self;
  final $Res Function(_MultiDocumentQueryResponseModel) _then;

/// Create a copy of MultiDocumentQueryResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answer = null,Object? sources = null,Object? documents = null,}) {
  return _then(_MultiDocumentQueryResponseModel(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<QueryCitationModel>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentMetadataModel>,
  ));
}


}

// dart format on
