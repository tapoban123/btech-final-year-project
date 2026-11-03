import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/app_formatters.dart';

class AudioPreviewer extends StatefulWidget {
  final String? filePath;
  final String title;
  final AudioPlayer? player;

  const AudioPreviewer({
    super.key,
    required this.filePath,
    required this.title,
    this.player,
  });

  @override
  State<AudioPreviewer> createState() => _AudioPreviewerState();
}

class _AudioPreviewerState extends State<AudioPreviewer> {
  // Static acoustic waveform profile representing natural audio levels
  static const List<double> _waveformWeights = [
    0.28, 0.45, 0.35, 0.68, 0.90, 0.74, 0.86, 0.52,
    0.80, 0.98, 0.84, 0.62, 0.44, 0.70, 0.92, 1.00,
    0.76, 0.58, 0.84, 0.66, 0.48, 0.64, 0.78, 0.44,
    0.56, 0.38, 0.30, 0.22,
  ];

  AudioPlayer? _player;
  bool _ownsPlayer = false;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _completeSubscription;

  String? get _resolvedFilePath {
    final raw = widget.filePath;
    if (raw == null || raw.trim().isEmpty) return null;
    if (raw.startsWith('file://')) {
      return Uri.parse(raw).toFilePath();
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _player = widget.player!;
      _ownsPlayer = false;
      _initPlayerListeners();
    } else {
      try {
        _player = AudioPlayer();
        _ownsPlayer = true;
        _initPlayerListeners();
      } catch (_) {
        // Platform channel not available or missing in hot reload
      }
    }
  }

  void _initPlayerListeners() {
    if (_player == null) return;
    try {
      _stateSubscription = _player!.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _positionSubscription = _player!.onPositionChanged.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });

      _durationSubscription = _player!.onDurationChanged.listen((dur) {
        if (mounted) {
          setState(() {
            _duration = dur;
          });
        }
      });

      _completeSubscription = _player!.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();

    if (_ownsPlayer) {
      try {
        _player?.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final path = _resolvedFilePath;
    if (path == null || _player == null) return;

    try {
      if (_isPlaying) {
        await _player!.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _player!.seek(Duration.zero);
        }
        await _player!.play(DeviceFileSource(path));
      }
    } catch (_) {
      // Gracefully handle playback failures or mock test environment
    }
  }

  Future<void> _onSeek(double seconds) async {
    final target = Duration(milliseconds: (seconds * 1000).round());
    setState(() => _position = target);
    try {
      await _player?.seek(target);
    } catch (_) {}
  }

  Widget _buildWaveformBars(double currentSeconds, double maxSeconds) {
    final progress =
        maxSeconds > 0 ? (currentSeconds / maxSeconds).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_waveformWeights.length, (i) {
          final barProgress = (i + 1) / _waveformWeights.length;
          final isPlayed = barProgress <= progress;
          final weight = _waveformWeights[i];

          // Static bar height representing acoustic waveform (no looping jumps)
          final barHeight = 8.0 + 34.0 * weight;

          final Color barColor = isPlayed
              ? AppColors.primary
              : AppColors.surfaceContainerHigh;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final targetSec = (i / _waveformWeights.length) * maxSeconds;
              _onSeek(targetSec);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                width: 3.5,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedFilePath;
    final fileExists = resolved != null && File(resolved).existsSync();

    if (!fileExists && widget.player == null) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.mic_none_outlined,
                size: 28,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Audio preview unavailable (file path not found)',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      );
    }

    final maxSeconds = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds / 1000.0
        : 1.0;
    final currentSeconds =
        (_position.inMilliseconds / 1000.0).clamp(0.0, maxSeconds);

    final formattedCurrent = AppFormatters.formatDuration(_position.inSeconds);
    final formattedTotal = AppFormatters.formatDuration(_duration.inSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Static waveform with progressive playhead highlight
          _buildWaveformBars(currentSeconds, maxSeconds),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 4,
            ),
            child: Slider(
              key: const Key('audio_preview_slider'),
              min: 0.0,
              max: maxSeconds,
              value: currentSeconds,
              onChanged: (val) {
                final target = Duration(milliseconds: (val * 1000).round());
                setState(() => _position = target);
              },
              onChangeEnd: _onSeek,
            ),
          ),

          // Time stamps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedCurrent,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedTotal,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Play/Pause Button
          IconButton(
            key: const Key('audio_preview_play_pause_button'),
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32,
              color: AppColors.onPrimary,
            ),
            tooltip: _isPlaying ? 'Pause' : 'Play',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(60, 60),
              shape: const CircleBorder(),
              elevation: 2,
            ),
            onPressed: _togglePlayPause,
          ),
        ],
      ),
    );
  }
}
