import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VoiceRecordingCard extends StatelessWidget {
  final bool isRecording;
  final String formattedTime;
  final String statusMessage;
  final VoidCallback onSaveAndIngest;
  final VoidCallback? onCancel;

  const VoiceRecordingCard({
    super.key,
    required this.isRecording,
    required this.formattedTime,
    required this.statusMessage,
    required this.onSaveAndIngest,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recording Voice Memo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.primary,
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
                  if (onCancel != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onCancel,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Central Waveform Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildWaveformBars(),
                const SizedBox(height: 12),
                Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Save & Ingest Action Button
          InkWell(
            onTap: onSaveAndIngest,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stop,
                    color: AppColors.onSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save & Ingest',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars() {
    final heights = [
      14.0,
      26.0,
      18.0,
      32.0,
      22.0,
      30.0,
      16.0,
      34.0,
      20.0,
      28.0,
      14.0,
      24.0,
      32.0,
      18.0,
      10.0
    ];

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: heights.map((h) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: 3.5,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
