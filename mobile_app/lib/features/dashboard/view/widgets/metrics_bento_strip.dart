import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../repository/models/document_item.dart';

class MetricsBentoStrip extends StatelessWidget {
  final DashboardMetrics metrics;

  const MetricsBentoStrip({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Synthesized Column
            Expanded(
              child: _MetricColumn(
                label: 'Synthesized',
                value: '${metrics.synthesizedDocsCount} Docs',
                valueColor: AppColors.primary,
              ),
            ),
            const VerticalDivider(
              color: AppColors.outlineVariant,
              thickness: 1,
              width: 24,
            ),
            // Audio Notes Column
            Expanded(
              child: _MetricColumn(
                label: 'Audio Notes',
                value: '${metrics.audioNotesHours} Hrs',
                valueColor: AppColors.secondary,
              ),
            ),
            const VerticalDivider(
              color: AppColors.outlineVariant,
              thickness: 1,
              width: 24,
            ),
            // Confidence Column
            Expanded(
              child: _MetricColumn(
                label: 'Confidence',
                value: '${metrics.confidencePercentage}%',
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleSm.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
