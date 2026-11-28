// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentUploadResponseModel {

 String? get id;@JsonKey(name: 'document_id') String? get documentId; String get filename;@JsonKey(name: 'content_type') String get contentType;@JsonKey(name: 'size_bytes') int get sizeBytes; String get status; String get message;@JsonKey(name: 'cloudinary_public_id') String? get cloudinaryPublicId;
/// Create a copy of DocumentUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentUploadResponseModelCopyWith<DocumentUploadResponseModel> get copyWith => _$DocumentUploadResponseModelCopyWithImpl<DocumentUploadResponseModel>(this as DocumentUploadResponseModel, _$identity);

  /// Serializes this DocumentUploadResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentUploadResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.cloudinaryPublicId, cloudinaryPublicId) || other.cloudinaryPublicId == cloudinaryPublicId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentId,filename,contentType,sizeBytes,status,message,cloudinaryPublicId);

@override
String toString() {
  return 'DocumentUploadResponseModel(id: $id, documentId: $documentId, filename: $filename, contentType: $contentType, sizeBytes: $sizeBytes, status: $status, message: $message, cloudinaryPublicId: $cloudinaryPublicId)';
}


}

/// @nodoc
abstract mixin class $DocumentUploadResponseModelCopyWith<$Res>  {
  factory $DocumentUploadResponseModelCopyWith(DocumentUploadResponseModel value, $Res Function(DocumentUploadResponseModel) _then) = _$DocumentUploadResponseModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'document_id') String? documentId, String filename,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'size_bytes') int sizeBytes, String status, String message,@JsonKey(name: 'cloudinary_public_id') String? cloudinaryPublicId
});




}
/// @nodoc
class _$DocumentUploadResponseModelCopyWithImpl<$Res>
    implements $DocumentUploadResponseModelCopyWith<$Res> {
  _$DocumentUploadResponseModelCopyWithImpl(this._self, this._then);

  final DocumentUploadResponseModel _self;
  final $Res Function(DocumentUploadResponseModel) _then;

/// Create a copy of DocumentUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? documentId = freezed,Object? filename = null,Object? contentType = null,Object? sizeBytes = null,Object? status = null,Object? message = null,Object? cloudinaryPublicId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cloudinaryPublicId: freezed == cloudinaryPublicId ? _self.cloudinaryPublicId : cloudinaryPublicId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentUploadResponseModel].
extension DocumentUploadResponseModelPatterns on DocumentUploadResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentUploadResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentUploadResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentUploadResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentUploadResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentUploadResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentUploadResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'document_id')  String? documentId,  String filename, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status,  String message, @JsonKey(name: 'cloudinary_public_id')  String? cloudinaryPublicId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentUploadResponseModel() when $default != null:
return $default(_that.id,_that.documentId,_that.filename,_that.contentType,_that.sizeBytes,_that.status,_that.message,_that.cloudinaryPublicId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'document_id')  String? documentId,  String filename, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status,  String message, @JsonKey(name: 'cloudinary_public_id')  String? cloudinaryPublicId)  $default,) {final _that = this;
switch (_that) {
case _DocumentUploadResponseModel():
return $default(_that.id,_that.documentId,_that.filename,_that.contentType,_that.sizeBytes,_that.status,_that.message,_that.cloudinaryPublicId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'document_id')  String? documentId,  String filename, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'size_bytes')  int sizeBytes,  String status,  String message, @JsonKey(name: 'cloudinary_public_id')  String? cloudinaryPublicId)?  $default,) {final _that = this;
switch (_that) {
case _DocumentUploadResponseModel() when $default != null:
return $default(_that.id,_that.documentId,_that.filename,_that.contentType,_that.sizeBytes,_that.status,_that.message,_that.cloudinaryPublicId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentUploadResponseModel extends DocumentUploadResponseModel {
  const _DocumentUploadResponseModel({this.id, @JsonKey(name: 'document_id') this.documentId, this.filename = '', @JsonKey(name: 'content_type') this.contentType = '', @JsonKey(name: 'size_bytes') this.sizeBytes = 0, this.status = 'completed', this.message = '', @JsonKey(name: 'cloudinary_public_id') this.cloudinaryPublicId}): super._();
  factory _DocumentUploadResponseModel.fromJson(Map<String, dynamic> json) => _$DocumentUploadResponseModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'document_id') final  String? documentId;
@override@JsonKey() final  String filename;
@override@JsonKey(name: 'content_type') final  String contentType;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override@JsonKey() final  String status;
@override@JsonKey() final  String message;
@override@JsonKey(name: 'cloudinary_public_id') final  String? cloudinaryPublicId;

/// Create a copy of DocumentUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentUploadResponseModelCopyWith<_DocumentUploadResponseModel> get copyWith => __$DocumentUploadResponseModelCopyWithImpl<_DocumentUploadResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentUploadResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentUploadResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.cloudinaryPublicId, cloudinaryPublicId) || other.cloudinaryPublicId == cloudinaryPublicId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentId,filename,contentType,sizeBytes,status,message,cloudinaryPublicId);

@override
String toString() {
  return 'DocumentUploadResponseModel(id: $id, documentId: $documentId, filename: $filename, contentType: $contentType, sizeBytes: $sizeBytes, status: $status, message: $message, cloudinaryPublicId: $cloudinaryPublicId)';
}


}

/// @nodoc
abstract mixin class _$DocumentUploadResponseModelCopyWith<$Res> implements $DocumentUploadResponseModelCopyWith<$Res> {
  factory _$DocumentUploadResponseModelCopyWith(_DocumentUploadResponseModel value, $Res Function(_DocumentUploadResponseModel) _then) = __$DocumentUploadResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'document_id') String? documentId, String filename,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'size_bytes') int sizeBytes, String status, String message,@JsonKey(name: 'cloudinary_public_id') String? cloudinaryPublicId
});




}
/// @nodoc
class __$DocumentUploadResponseModelCopyWithImpl<$Res>
    implements _$DocumentUploadResponseModelCopyWith<$Res> {
  __$DocumentUploadResponseModelCopyWithImpl(this._self, this._then);

  final _DocumentUploadResponseModel _self;
  final $Res Function(_DocumentUploadResponseModel) _then;

/// Create a copy of DocumentUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? documentId = freezed,Object? filename = null,Object? contentType = null,Object? sizeBytes = null,Object? status = null,Object? message = null,Object? cloudinaryPublicId = freezed,}) {
  return _then(_DocumentUploadResponseModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cloudinaryPublicId: freezed == cloudinaryPublicId ? _self.cloudinaryPublicId : cloudinaryPublicId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentBatchUploadResponseModel {

@JsonKey(name: 'total_files') int get totalFiles; int get successful; int get failed; List<DocumentUploadResponseModel> get results;
/// Create a copy of DocumentBatchUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentBatchUploadResponseModelCopyWith<DocumentBatchUploadResponseModel> get copyWith => _$DocumentBatchUploadResponseModelCopyWithImpl<DocumentBatchUploadResponseModel>(this as DocumentBatchUploadResponseModel, _$identity);

  /// Serializes this DocumentBatchUploadResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentBatchUploadResponseModel&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.successful, successful) || other.successful == successful)&&(identical(other.failed, failed) || other.failed == failed)&&const DeepCollectionEquality().equals(other.results, results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalFiles,successful,failed,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return 'DocumentBatchUploadResponseModel(totalFiles: $totalFiles, successful: $successful, failed: $failed, results: $results)';
}


}

/// @nodoc
abstract mixin class $DocumentBatchUploadResponseModelCopyWith<$Res>  {
  factory $DocumentBatchUploadResponseModelCopyWith(DocumentBatchUploadResponseModel value, $Res Function(DocumentBatchUploadResponseModel) _then) = _$DocumentBatchUploadResponseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_files') int totalFiles, int successful, int failed, List<DocumentUploadResponseModel> results
});




}
/// @nodoc
class _$DocumentBatchUploadResponseModelCopyWithImpl<$Res>
    implements $DocumentBatchUploadResponseModelCopyWith<$Res> {
  _$DocumentBatchUploadResponseModelCopyWithImpl(this._self, this._then);

  final DocumentBatchUploadResponseModel _self;
  final $Res Function(DocumentBatchUploadResponseModel) _then;

/// Create a copy of DocumentBatchUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalFiles = null,Object? successful = null,Object? failed = null,Object? results = null,}) {
  return _then(_self.copyWith(
totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,successful: null == successful ? _self.successful : successful // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<DocumentUploadResponseModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentBatchUploadResponseModel].
extension DocumentBatchUploadResponseModelPatterns on DocumentBatchUploadResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentBatchUploadResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentBatchUploadResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentBatchUploadResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_files')  int totalFiles,  int successful,  int failed,  List<DocumentUploadResponseModel> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel() when $default != null:
return $default(_that.totalFiles,_that.successful,_that.failed,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_files')  int totalFiles,  int successful,  int failed,  List<DocumentUploadResponseModel> results)  $default,) {final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel():
return $default(_that.totalFiles,_that.successful,_that.failed,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_files')  int totalFiles,  int successful,  int failed,  List<DocumentUploadResponseModel> results)?  $default,) {final _that = this;
switch (_that) {
case _DocumentBatchUploadResponseModel() when $default != null:
return $default(_that.totalFiles,_that.successful,_that.failed,_that.results);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentBatchUploadResponseModel implements DocumentBatchUploadResponseModel {
  const _DocumentBatchUploadResponseModel({@JsonKey(name: 'total_files') this.totalFiles = 0, this.successful = 0, this.failed = 0, final  List<DocumentUploadResponseModel> results = const []}): _results = results;
  factory _DocumentBatchUploadResponseModel.fromJson(Map<String, dynamic> json) => _$DocumentBatchUploadResponseModelFromJson(json);

@override@JsonKey(name: 'total_files') final  int totalFiles;
@override@JsonKey() final  int successful;
@override@JsonKey() final  int failed;
 final  List<DocumentUploadResponseModel> _results;
@override@JsonKey() List<DocumentUploadResponseModel> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of DocumentBatchUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentBatchUploadResponseModelCopyWith<_DocumentBatchUploadResponseModel> get copyWith => __$DocumentBatchUploadResponseModelCopyWithImpl<_DocumentBatchUploadResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentBatchUploadResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentBatchUploadResponseModel&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.successful, successful) || other.successful == successful)&&(identical(other.failed, failed) || other.failed == failed)&&const DeepCollectionEquality().equals(other._results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalFiles,successful,failed,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'DocumentBatchUploadResponseModel(totalFiles: $totalFiles, successful: $successful, failed: $failed, results: $results)';
}


}

/// @nodoc
abstract mixin class _$DocumentBatchUploadResponseModelCopyWith<$Res> implements $DocumentBatchUploadResponseModelCopyWith<$Res> {
  factory _$DocumentBatchUploadResponseModelCopyWith(_DocumentBatchUploadResponseModel value, $Res Function(_DocumentBatchUploadResponseModel) _then) = __$DocumentBatchUploadResponseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_files') int totalFiles, int successful, int failed, List<DocumentUploadResponseModel> results
});




}
/// @nodoc
class __$DocumentBatchUploadResponseModelCopyWithImpl<$Res>
    implements _$DocumentBatchUploadResponseModelCopyWith<$Res> {
  __$DocumentBatchUploadResponseModelCopyWithImpl(this._self, this._then);

  final _DocumentBatchUploadResponseModel _self;
  final $Res Function(_DocumentBatchUploadResponseModel) _then;

/// Create a copy of DocumentBatchUploadResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalFiles = null,Object? successful = null,Object? failed = null,Object? results = null,}) {
  return _then(_DocumentBatchUploadResponseModel(
totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,successful: null == successful ? _self.successful : successful // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<DocumentUploadResponseModel>,
  ));
}


}


/// @nodoc
mixin _$VoiceMemoResponseModel {

 String get id; String get title; String get type;@JsonKey(name: 'stage_description') String get stageDescription; String get status;
/// Create a copy of VoiceMemoResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceMemoResponseModelCopyWith<VoiceMemoResponseModel> get copyWith => _$VoiceMemoResponseModelCopyWithImpl<VoiceMemoResponseModel>(this as VoiceMemoResponseModel, _$identity);

  /// Serializes this VoiceMemoResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceMemoResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.stageDescription, stageDescription) || other.stageDescription == stageDescription)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,stageDescription,status);

@override
String toString() {
  return 'VoiceMemoResponseModel(id: $id, title: $title, type: $type, stageDescription: $stageDescription, status: $status)';
}


}

/// @nodoc
abstract mixin class $VoiceMemoResponseModelCopyWith<$Res>  {
  factory $VoiceMemoResponseModelCopyWith(VoiceMemoResponseModel value, $Res Function(VoiceMemoResponseModel) _then) = _$VoiceMemoResponseModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String type,@JsonKey(name: 'stage_description') String stageDescription, String status
});




}
/// @nodoc
class _$VoiceMemoResponseModelCopyWithImpl<$Res>
    implements $VoiceMemoResponseModelCopyWith<$Res> {
  _$VoiceMemoResponseModelCopyWithImpl(this._self, this._then);

  final VoiceMemoResponseModel _self;
  final $Res Function(VoiceMemoResponseModel) _then;

/// Create a copy of VoiceMemoResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? type = null,Object? stageDescription = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,stageDescription: null == stageDescription ? _self.stageDescription : stageDescription // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceMemoResponseModel].
extension VoiceMemoResponseModelPatterns on VoiceMemoResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceMemoResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceMemoResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceMemoResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _VoiceMemoResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceMemoResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceMemoResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String type, @JsonKey(name: 'stage_description')  String stageDescription,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceMemoResponseModel() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.stageDescription,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String type, @JsonKey(name: 'stage_description')  String stageDescription,  String status)  $default,) {final _that = this;
switch (_that) {
case _VoiceMemoResponseModel():
return $default(_that.id,_that.title,_that.type,_that.stageDescription,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String type, @JsonKey(name: 'stage_description')  String stageDescription,  String status)?  $default,) {final _that = this;
switch (_that) {
case _VoiceMemoResponseModel() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.stageDescription,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceMemoResponseModel implements VoiceMemoResponseModel {
  const _VoiceMemoResponseModel({required this.id, required this.title, this.type = 'audio', @JsonKey(name: 'stage_description') this.stageDescription = '', this.status = 'processing'});
  factory _VoiceMemoResponseModel.fromJson(Map<String, dynamic> json) => _$VoiceMemoResponseModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String type;
@override@JsonKey(name: 'stage_description') final  String stageDescription;
@override@JsonKey() final  String status;

/// Create a copy of VoiceMemoResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceMemoResponseModelCopyWith<_VoiceMemoResponseModel> get copyWith => __$VoiceMemoResponseModelCopyWithImpl<_VoiceMemoResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceMemoResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceMemoResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.stageDescription, stageDescription) || other.stageDescription == stageDescription)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,stageDescription,status);

@override
String toString() {
  return 'VoiceMemoResponseModel(id: $id, title: $title, type: $type, stageDescription: $stageDescription, status: $status)';
}


}

/// @nodoc
abstract mixin class _$VoiceMemoResponseModelCopyWith<$Res> implements $VoiceMemoResponseModelCopyWith<$Res> {
  factory _$VoiceMemoResponseModelCopyWith(_VoiceMemoResponseModel value, $Res Function(_VoiceMemoResponseModel) _then) = __$VoiceMemoResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String type,@JsonKey(name: 'stage_description') String stageDescription, String status
});




}
/// @nodoc
class __$VoiceMemoResponseModelCopyWithImpl<$Res>
    implements _$VoiceMemoResponseModelCopyWith<$Res> {
  __$VoiceMemoResponseModelCopyWithImpl(this._self, this._then);

  final _VoiceMemoResponseModel _self;
  final $Res Function(_VoiceMemoResponseModel) _then;

/// Create a copy of VoiceMemoResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? type = null,Object? stageDescription = null,Object? status = null,}) {
  return _then(_VoiceMemoResponseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,stageDescription: null == stageDescription ? _self.stageDescription : stageDescription // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
