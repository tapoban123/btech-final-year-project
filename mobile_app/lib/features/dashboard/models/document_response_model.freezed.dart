// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentMetadataModel {

@JsonKey(name: 'document_id') String get documentId; String get id; String get filename;@JsonKey(name: 'size_bytes') int get sizeBytes; String get status;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'cloudinary_url') String? get cloudinaryUrl;@JsonKey(name: 'mime_type') String? get mimeType;
/// Create a copy of DocumentMetadataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentMetadataModelCopyWith<DocumentMetadataModel> get copyWith => _$DocumentMetadataModelCopyWithImpl<DocumentMetadataModel>(this as DocumentMetadataModel, _$identity);

  /// Serializes this DocumentMetadataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentMetadataModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,id,filename,sizeBytes,status,createdAt,cloudinaryUrl,mimeType);

@override
String toString() {
  return 'DocumentMetadataModel(documentId: $documentId, id: $id, filename: $filename, sizeBytes: $sizeBytes, status: $status, createdAt: $createdAt, cloudinaryUrl: $cloudinaryUrl, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class $DocumentMetadataModelCopyWith<$Res>  {
  factory $DocumentMetadataModelCopyWith(DocumentMetadataModel value, $Res Function(DocumentMetadataModel) _then) = _$DocumentMetadataModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String id, String filename,@JsonKey(name: 'size_bytes') int sizeBytes, String status,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,@JsonKey(name: 'mime_type') String? mimeType
});




}
/// @nodoc
class _$DocumentMetadataModelCopyWithImpl<$Res>
    implements $DocumentMetadataModelCopyWith<$Res> {
  _$DocumentMetadataModelCopyWithImpl(this._self, this._then);

  final DocumentMetadataModel _self;
  final $Res Function(DocumentMetadataModel) _then;

/// Create a copy of DocumentMetadataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? id = null,Object? filename = null,Object? sizeBytes = null,Object? status = null,Object? createdAt = freezed,Object? cloudinaryUrl = freezed,Object? mimeType = freezed,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentMetadataModel].
extension DocumentMetadataModelPatterns on DocumentMetadataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentMetadataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentMetadataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentMetadataModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentMetadataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentMetadataModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentMetadataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String id,  String filename, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentMetadataModel() when $default != null:
return $default(_that.documentId,_that.id,_that.filename,_that.sizeBytes,_that.status,_that.createdAt,_that.cloudinaryUrl,_that.mimeType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_id')  String documentId,  String id,  String filename, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)  $default,) {final _that = this;
switch (_that) {
case _DocumentMetadataModel():
return $default(_that.documentId,_that.id,_that.filename,_that.sizeBytes,_that.status,_that.createdAt,_that.cloudinaryUrl,_that.mimeType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_id')  String documentId,  String id,  String filename, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'cloudinary_url')  String? cloudinaryUrl, @JsonKey(name: 'mime_type')  String? mimeType)?  $default,) {final _that = this;
switch (_that) {
case _DocumentMetadataModel() when $default != null:
return $default(_that.documentId,_that.id,_that.filename,_that.sizeBytes,_that.status,_that.createdAt,_that.cloudinaryUrl,_that.mimeType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentMetadataModel extends DocumentMetadataModel {
  const _DocumentMetadataModel({@JsonKey(name: 'document_id') this.documentId = '', this.id = '', this.filename = 'Untitled', @JsonKey(name: 'size_bytes') this.sizeBytes = 0, this.status = 'completed', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'cloudinary_url') this.cloudinaryUrl, @JsonKey(name: 'mime_type') this.mimeType}): super._();
  factory _DocumentMetadataModel.fromJson(Map<String, dynamic> json) => _$DocumentMetadataModelFromJson(json);

@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey() final  String id;
@override@JsonKey() final  String filename;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'cloudinary_url') final  String? cloudinaryUrl;
@override@JsonKey(name: 'mime_type') final  String? mimeType;

/// Create a copy of DocumentMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentMetadataModelCopyWith<_DocumentMetadataModel> get copyWith => __$DocumentMetadataModelCopyWithImpl<_DocumentMetadataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentMetadataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentMetadataModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cloudinaryUrl, cloudinaryUrl) || other.cloudinaryUrl == cloudinaryUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,id,filename,sizeBytes,status,createdAt,cloudinaryUrl,mimeType);

@override
String toString() {
  return 'DocumentMetadataModel(documentId: $documentId, id: $id, filename: $filename, sizeBytes: $sizeBytes, status: $status, createdAt: $createdAt, cloudinaryUrl: $cloudinaryUrl, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class _$DocumentMetadataModelCopyWith<$Res> implements $DocumentMetadataModelCopyWith<$Res> {
  factory _$DocumentMetadataModelCopyWith(_DocumentMetadataModel value, $Res Function(_DocumentMetadataModel) _then) = __$DocumentMetadataModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_id') String documentId, String id, String filename,@JsonKey(name: 'size_bytes') int sizeBytes, String status,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'cloudinary_url') String? cloudinaryUrl,@JsonKey(name: 'mime_type') String? mimeType
});




}
/// @nodoc
class __$DocumentMetadataModelCopyWithImpl<$Res>
    implements _$DocumentMetadataModelCopyWith<$Res> {
  __$DocumentMetadataModelCopyWithImpl(this._self, this._then);

  final _DocumentMetadataModel _self;
  final $Res Function(_DocumentMetadataModel) _then;

/// Create a copy of DocumentMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? id = null,Object? filename = null,Object? sizeBytes = null,Object? status = null,Object? createdAt = freezed,Object? cloudinaryUrl = freezed,Object? mimeType = freezed,}) {
  return _then(_DocumentMetadataModel(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,cloudinaryUrl: freezed == cloudinaryUrl ? _self.cloudinaryUrl : cloudinaryUrl // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentsResponseModel {

 List<DocumentMetadataModel> get documents;
/// Create a copy of DocumentsResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentsResponseModelCopyWith<DocumentsResponseModel> get copyWith => _$DocumentsResponseModelCopyWithImpl<DocumentsResponseModel>(this as DocumentsResponseModel, _$identity);

  /// Serializes this DocumentsResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentsResponseModel&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'DocumentsResponseModel(documents: $documents)';
}


}

/// @nodoc
abstract mixin class $DocumentsResponseModelCopyWith<$Res>  {
  factory $DocumentsResponseModelCopyWith(DocumentsResponseModel value, $Res Function(DocumentsResponseModel) _then) = _$DocumentsResponseModelCopyWithImpl;
@useResult
$Res call({
 List<DocumentMetadataModel> documents
});




}
/// @nodoc
class _$DocumentsResponseModelCopyWithImpl<$Res>
    implements $DocumentsResponseModelCopyWith<$Res> {
  _$DocumentsResponseModelCopyWithImpl(this._self, this._then);

  final DocumentsResponseModel _self;
  final $Res Function(DocumentsResponseModel) _then;

/// Create a copy of DocumentsResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documents = null,}) {
  return _then(_self.copyWith(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentMetadataModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentsResponseModel].
extension DocumentsResponseModelPatterns on DocumentsResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentsResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentsResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentsResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentsResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentsResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentsResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DocumentMetadataModel> documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentsResponseModel() when $default != null:
return $default(_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DocumentMetadataModel> documents)  $default,) {final _that = this;
switch (_that) {
case _DocumentsResponseModel():
return $default(_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DocumentMetadataModel> documents)?  $default,) {final _that = this;
switch (_that) {
case _DocumentsResponseModel() when $default != null:
return $default(_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentsResponseModel implements DocumentsResponseModel {
  const _DocumentsResponseModel({final  List<DocumentMetadataModel> documents = const []}): _documents = documents;
  factory _DocumentsResponseModel.fromJson(Map<String, dynamic> json) => _$DocumentsResponseModelFromJson(json);

 final  List<DocumentMetadataModel> _documents;
@override@JsonKey() List<DocumentMetadataModel> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}


/// Create a copy of DocumentsResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentsResponseModelCopyWith<_DocumentsResponseModel> get copyWith => __$DocumentsResponseModelCopyWithImpl<_DocumentsResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentsResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentsResponseModel&&const DeepCollectionEquality().equals(other._documents, _documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_documents));

@override
String toString() {
  return 'DocumentsResponseModel(documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$DocumentsResponseModelCopyWith<$Res> implements $DocumentsResponseModelCopyWith<$Res> {
  factory _$DocumentsResponseModelCopyWith(_DocumentsResponseModel value, $Res Function(_DocumentsResponseModel) _then) = __$DocumentsResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<DocumentMetadataModel> documents
});




}
/// @nodoc
class __$DocumentsResponseModelCopyWithImpl<$Res>
    implements _$DocumentsResponseModelCopyWith<$Res> {
  __$DocumentsResponseModelCopyWithImpl(this._self, this._then);

  final _DocumentsResponseModel _self;
  final $Res Function(_DocumentsResponseModel) _then;

/// Create a copy of DocumentsResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documents = null,}) {
  return _then(_DocumentsResponseModel(
documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentMetadataModel>,
  ));
}


}

// dart format on
