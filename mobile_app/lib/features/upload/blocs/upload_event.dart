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

class TriggerFileUpload extends UploadEvent {
  final String filename;
  final DocumentType type;

  const TriggerFileUpload({
    required this.filename,
    required this.type,
  });

  @override
  List<Object?> get props => [filename, type];
}

class StartVoiceRecording extends UploadEvent {
  const StartVoiceRecording();
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
