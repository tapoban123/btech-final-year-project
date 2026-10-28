import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract class IAudioRecordingService {
  Future<bool> hasPermission();
  Future<void> start({String? path});
  Future<String?> stop();
  Future<void> cancel();
  Stream<double> get onAmplitudeChanged;
  Future<bool> isRecording();
  void dispose();
}

class AudioRecordingService implements IAudioRecordingService {
  final AudioRecorder _recorder;
  String? _currentRecordingPath;

  AudioRecordingService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<void> start({String? path}) async {
    const config = RecordConfig(encoder: AudioEncoder.aacLc);
    String savePath = path ?? '';
    if (savePath.isEmpty) {
      try {
        final tempDir = await getTemporaryDirectory();
        savePath =
            '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } catch (_) {
        savePath =
            '/tmp/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
    }
    _currentRecordingPath = savePath;
    await _recorder.start(config, path: savePath);
  }

  @override
  Future<String?> stop() async {
    final stoppedPath = await _recorder.stop();
    final result = (stoppedPath != null && stoppedPath.isNotEmpty)
        ? stoppedPath
        : _currentRecordingPath;
    _currentRecordingPath = null;
    return result;
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    _currentRecordingPath = null;
  }

  @override
  Stream<double> get onAmplitudeChanged {
    return _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .map((amp) => _normalizeDb(amp.current));
  }

  @override
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  @override
  void dispose() {
    _recorder.dispose();
  }

  double _normalizeDb(double db) {
    if (db < -50) return 0.05;
    if (db > 0) return 1.0;
    return 0.05 + 0.95 * ((db + 50) / 50);
  }
}
