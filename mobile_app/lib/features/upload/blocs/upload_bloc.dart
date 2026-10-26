import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/upload_repository.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final IUploadRepository _repository;

  UploadBloc({IUploadRepository? repository})
      : _repository = repository ?? UploadRepository(),
        super(const UploadState()) {
    on<LoadUploadData>(_onLoadUploadData);
    on<TriggerFileUpload>(_onTriggerFileUpload);
    on<StartVoiceRecording>(_onStartVoiceRecording);
    on<StopAndSaveVoiceRecording>(_onStopAndSaveVoiceRecording);
    on<UpdateRecordingDuration>(_onUpdateRecordingDuration);
  }

  Future<void> _onLoadUploadData(
    LoadUploadData event,
    Emitter<UploadState> emit,
  ) async {
    emit(state.copyWith(status: UploadScreenStatus.loading));
    try {
      final uploads = await _repository.getRecentUploads();
      emit(state.copyWith(
        status: UploadScreenStatus.success,
        recentUploads: uploads,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UploadScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTriggerFileUpload(
    TriggerFileUpload event,
    Emitter<UploadState> emit,
  ) async {
    try {
      final newItem = await _repository.uploadFile(event.filename, event.type);
      final updatedList = List.of(state.recentUploads)..insert(0, newItem);
      emit(state.copyWith(recentUploads: updatedList));
    } catch (e) {
      emit(state.copyWith(
        status: UploadScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStartVoiceRecording(
    StartVoiceRecording event,
    Emitter<UploadState> emit,
  ) {
    emit(state.copyWith(
      isRecording: true,
      recordingDurationSeconds: 0,
      speechDetectionMessage: 'Listening: Multimodal vector ingestion live',
    ));
  }

  Future<void> _onStopAndSaveVoiceRecording(
    StopAndSaveVoiceRecording event,
    Emitter<UploadState> emit,
  ) async {
    emit(state.copyWith(isRecording: false));
    try {
      final savedItem =
          await _repository.saveVoiceMemo(state.recordingDurationSeconds);
      final updated = List.of(state.recentUploads)..insert(0, savedItem);
      emit(state.copyWith(
        recentUploads: updated,
        status: UploadScreenStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UploadScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateRecordingDuration(
    UpdateRecordingDuration event,
    Emitter<UploadState> emit,
  ) {
    emit(state.copyWith(recordingDurationSeconds: event.seconds));
  }
}
