import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VoiceRecordingCard extends StatelessWidget {
  final bool isRecording;
  final String formattedTime;
  final double amplitude;
  final VoidCallback onRecord;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback? onCancel;

  const VoiceRecordingCard({
    super.key,
    required this.isRecording,
    required this.formattedTime,
    this.amplitude = 0.0,
    required this.onRecord,
    required this.onDone,
    required this.onDelete,
    this.onCancel,
  });

  static const List<double> _barWeights = [
    0.35, 0.5, 0.7, 0.85, 0.65, 0.95, 1.0, 0.8,
    0.9, 0.75, 1.0, 0.85, 0.9, 0.7, 0.85, 0.6,
    0.75, 0.9, 0.65, 0.8, 0.55, 0.7, 0.45, 0.3,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecording
              ? AppColors.secondary.withValues(alpha: 0.5)
              : AppColors.outlineVariant,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRecording ? AppColors.error : AppColors.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording ? 'Recording Voice Note' : 'Voice Note',
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: isRecording
                          ? AppColors.secondary
                          : AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Central Waveform Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWaveformBars(),
                const SizedBox(height: 8),
                Text(
                  isRecording ? 'Listening...' : 'Tap mic to speak',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSm.copyWith(
                    color: isRecording
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight:
                        isRecording ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Deck: Delete, Record (disabled once recording), Check for Done
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Delete / Discard Button
              IconButton(
                key: const Key('voice_recorder_delete_button'),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
                tooltip: 'Delete recording',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                  minimumSize: const Size(48, 48),
                  shape: const CircleBorder(),
                ),
                onPressed: onDelete,
              ),

              // 2. Record / Tap to Speak Button (Disabled once started recording)
              IconButton(
                key: const Key('voice_recorder_record_button'),
                icon: Icon(
                  isRecording ? Icons.mic : Icons.mic_none,
                  color: isRecording
                      ? AppColors.outline.withValues(alpha: 0.6)
                      : AppColors.onPrimary,
                  size: 26,
                ),
                tooltip: isRecording ? 'Recording active' : 'Tap to speak',
                style: IconButton.styleFrom(
                  backgroundColor: isRecording
                      ? AppColors.surfaceContainerLow
                      : AppColors.primary,
                  minimumSize: const Size(56, 56),
                  shape: const CircleBorder(),
                  elevation: isRecording ? 0 : 2,
                ),
                onPressed: isRecording ? null : onRecord,
              ),

              // 3. Check for Done Button
              IconButton(
                key: const Key('voice_recorder_done_button'),
                icon: Icon(
                  Icons.check,
                  color: isRecording
                      ? AppColors.onSecondary
                      : AppColors.outline,
                  size: 24,
                ),
                tooltip: 'Done',
                style: IconButton.styleFrom(
                  backgroundColor: isRecording
                      ? AppColors.secondary
                      : AppColors.surfaceContainerLow,
                  minimumSize: const Size(48, 48),
                  shape: const CircleBorder(),
                  elevation: isRecording ? 2 : 0,
                ),
                onPressed: onDone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars() {
    return SizedBox(
      height: 42,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barWeights.length, (index) {
          final weight = _barWeights[index];
          final double barHeight;
          if (isRecording) {
            final effectiveAmp = amplitude <= 0 ? 0.2 : amplitude;
            barHeight = (6.0 + 34.0 * (effectiveAmp * weight)).clamp(6.0, 40.0);
          } else {
            barHeight = 6.0;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutQuad,
              width: 3.5,
              height: barHeight,
              decoration: BoxDecoration(
                color: isRecording
                    ? AppColors.secondary
                    : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
