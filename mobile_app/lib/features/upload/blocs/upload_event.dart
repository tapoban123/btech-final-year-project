import 'package:equatable/equatable.dart';
import '../../dashboard/repository/models/document_item.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class LoadUploadData extends UploadEvent {
  const LoadUploadData();
}

class SelectedFileInfo extends Equatable {
  final String filename;
  final DocumentType type;
  final String? filePath;
  final int? fileSize;

  const SelectedFileInfo({
    required this.filename,
    required this.type,
    this.filePath,
    this.fileSize,
  });

  @override
  List<Object?> get props => [filename, type, filePath, fileSize];
}

class TriggerFileUpload extends UploadEvent {
  final String filename;
  final DocumentType type;
  final String? filePath;
  final int? fileSize;

  const TriggerFileUpload({
    required this.filename,
    required this.type,
    this.filePath,
    this.fileSize,
  });

  @override
  List<Object?> get props => [filename, type, filePath, fileSize];
}

class TriggerMultipleFilesUpload extends UploadEvent {
  final List<SelectedFileInfo> files;

  const TriggerMultipleFilesUpload(this.files);

  @override
  List<Object?> get props => [files];
}

class OpenVoiceRecorder extends UploadEvent {
  const OpenVoiceRecorder();
}

class StartVoiceRecording extends UploadEvent {
  const StartVoiceRecording();
}

class UpdateVoiceAmplitude extends UploadEvent {
  final double amplitude;

  const UpdateVoiceAmplitude(this.amplitude);

  @override
  List<Object?> get props => [amplitude];
}

class CancelVoiceRecording extends UploadEvent {
  const CancelVoiceRecording();
}

class StopAndSaveVoiceRecording extends UploadEvent {
  const StopAndSaveVoiceRecording();
}

class UpdateRecordingDuration extends UploadEvent {
  final int seconds;

  const UpdateRecordingDuration(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class RemoveUploadItem extends UploadEvent {
  final String itemId;

  const RemoveUploadItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ConfirmAndUploadAll extends UploadEvent {
  const ConfirmAndUploadAll();
}
