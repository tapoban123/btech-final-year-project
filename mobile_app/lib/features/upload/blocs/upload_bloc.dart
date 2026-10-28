import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_formatters.dart';
import '../repository/models/upload_item.dart';
import '../repository/upload_repository.dart';
import '../services/audio_recording_service.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final IUploadRepository _repository;
  final IAudioRecordingService _audioRecordingService;
  StreamSubscription<double>? _amplitudeSubscription;
  Timer? _recordingTimer;

  UploadBloc({
    IUploadRepository? repository,
    IAudioRecordingService? audioRecordingService,
  })  : _repository = repository ?? UploadRepository(),
        _audioRecordingService =
            audioRecordingService ?? AudioRecordingService(),
        super(const UploadState()) {
    on<LoadUploadData>(_onLoadUploadData);
    on<TriggerFileUpload>(_onTriggerFileUpload);
    on<TriggerMultipleFilesUpload>(_onTriggerMultipleFilesUpload);
    on<RemoveUploadItem>(_onRemoveUploadItem);
    on<ConfirmAndUploadAll>(_onConfirmAndUploadAll);
    on<OpenVoiceRecorder>(_onOpenVoiceRecorder);
    on<StartVoiceRecording>(_onStartVoiceRecording);
    on<UpdateVoiceAmplitude>(_onUpdateVoiceAmplitude);
    on<CancelVoiceRecording>(_onCancelVoiceRecording);
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

  void _onTriggerFileUpload(
    TriggerFileUpload event,
    Emitter<UploadState> emit,
  ) {
    final sizeDesc = event.fileSize != null
        ? AppFormatters.formatFileSizeInMb(event.fileSize! / 1048576)
        : '';
    final stagedItem = UploadItem(
      id: 'staged_${event.filename}_${DateTime.now().microsecondsSinceEpoch}',
      title: event.filename,
      type: event.type,
      stageDescription: sizeDesc,
      status: UploadProcessingStatus.queued,
      filePath: event.filePath,
      fileSize: event.fileSize,
    );
    final updatedList = List.of(state.recentUploads)..insert(0, stagedItem);
    emit(state.copyWith(
      recentUploads: updatedList,
      status: UploadScreenStatus.success,
    ));
  }

  void _onTriggerMultipleFilesUpload(
    TriggerMultipleFilesUpload event,
    Emitter<UploadState> emit,
  ) {
    if (event.files.isEmpty) return;
    final stagedItems = event.files.map((file) {
      final sizeDesc = file.fileSize != null
          ? AppFormatters.formatFileSizeInMb(file.fileSize! / 1048576)
          : '';
      return UploadItem(
        id: 'staged_${file.filename}_${DateTime.now().microsecondsSinceEpoch}',
        title: file.filename,
        type: file.type,
        stageDescription: sizeDesc,
        status: UploadProcessingStatus.queued,
        filePath: file.filePath,
        fileSize: file.fileSize,
      );
    }).toList();
    final updatedList = List.of(state.recentUploads)..insertAll(0, stagedItems);
    emit(state.copyWith(
      recentUploads: updatedList,
      status: UploadScreenStatus.success,
    ));
  }

  void _onRemoveUploadItem(
    RemoveUploadItem event,
    Emitter<UploadState> emit,
  ) {
    final updatedList =
        state.recentUploads.where((item) => item.id != event.itemId).toList();
    emit(state.copyWith(
      recentUploads: updatedList,
    ));
  }

  Future<void> _onConfirmAndUploadAll(
    ConfirmAndUploadAll event,
    Emitter<UploadState> emit,
  ) async {
    final itemsToUpload = state.recentUploads
        .where((item) => item.status != UploadProcessingStatus.completed)
        .toList();

    if (itemsToUpload.isEmpty) return;

    // Transition all queued items to processing
    emit(state.copyWith(
      isUploading: true,
      status: UploadScreenStatus.loading,
      recentUploads: state.recentUploads.map((item) {
        if (item.status != UploadProcessingStatus.completed) {
          return item.copyWith(
            status: UploadProcessingStatus.processing,
          );
        }
        return item;
      }).toList(),
    ));

    try {
      // Execute all uploads in parallel
      final uploadFutures = itemsToUpload.map((item) async {
        return await _repository.uploadFile(
          item.title,
          item.type,
          filePath: item.filePath,
          fileSize: item.fileSize,
        );
      }).toList();

      final results = await Future.wait(uploadFutures);

      final resultMap = {for (var r in results) r.title: r};
      final updatedList = state.recentUploads.map((item) {
        final result = resultMap[item.title];
        if (result != null) {
          return result.copyWith(
            status: UploadProcessingStatus.completed,
            stageDescription: item.stageDescription,
          );
        }
        return item;
      }).toList();

      emit(state.copyWith(
        isUploading: false,
        status: UploadScreenStatus.success,
        recentUploads: updatedList,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        status: UploadScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onOpenVoiceRecorder(
    OpenVoiceRecorder event,
    Emitter<UploadState> emit,
  ) {
    emit(state.copyWith(
      isRecordingCardVisible: true,
      isRecording: false,
      recordingDurationSeconds: 0,
      currentAmplitude: 0.0,
      speechDetectionMessage: 'Listening...',
    ));
  }

  Future<void> _onStartVoiceRecording(
    StartVoiceRecording event,
    Emitter<UploadState> emit,
  ) async {
    try {
      final hasPermission = await _audioRecordingService.hasPermission();
      if (!hasPermission) {
        emit(state.copyWith(
          status: UploadScreenStatus.failure,
          errorMessage:
              'Microphone permission is required to record voice notes',
        ));
        return;
      }

      await _audioRecordingService.start();

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(UpdateRecordingDuration(state.recordingDurationSeconds + 1));
      });

      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _audioRecordingService.onAmplitudeChanged.listen(
        (amp) => add(UpdateVoiceAmplitude(amp)),
      );

      emit(state.copyWith(
        isRecordingCardVisible: true,
        isRecording: true,
        recordingDurationSeconds: 0,
        currentAmplitude: 0.15,
        speechDetectionMessage: 'Listening...',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UploadScreenStatus.failure,
        errorMessage: 'Failed to start recording: ${e.toString()}',
      ));
    }
  }

  void _onUpdateVoiceAmplitude(
    UpdateVoiceAmplitude event,
    Emitter<UploadState> emit,
  ) {
    if (!state.isRecording) return;
    emit(state.copyWith(currentAmplitude: event.amplitude));
  }

  Future<void> _onCancelVoiceRecording(
    CancelVoiceRecording event,
    Emitter<UploadState> emit,
  ) async {
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    await _audioRecordingService.cancel();
    emit(state.copyWith(
      isRecording: false,
      isRecordingCardVisible: false,
      recordingDurationSeconds: 0,
      currentAmplitude: 0.0,
    ));
  }

  Future<void> _onStopAndSaveVoiceRecording(
    StopAndSaveVoiceRecording event,
    Emitter<UploadState> emit,
  ) async {
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    final duration = state.recordingDurationSeconds;
    final durationFormatted = state.formattedDuration;
    emit(state.copyWith(isRecording: false));

    try {
      final filePath = await _audioRecordingService.stop();
      final savedItem = await _repository.saveVoiceMemo(duration);

      final stagedMemo = savedItem.copyWith(
        filePath: filePath,
        stageDescription: durationFormatted,
        status: UploadProcessingStatus.queued,
      );

      final updated = List.of(state.recentUploads)..insert(0, stagedMemo);
      emit(state.copyWith(
        isRecordingCardVisible: false,
        recordingDurationSeconds: 0,
        currentAmplitude: 0.0,
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

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _audioRecordingService.dispose();
    return super.close();
  }
}
