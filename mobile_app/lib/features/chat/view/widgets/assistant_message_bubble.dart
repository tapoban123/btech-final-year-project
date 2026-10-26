import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../repository/models/chat_message.dart';
import 'grounding_citation_card.dart';

class AssistantMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAccurateTap;
  final VoidCallback? onExportTap;

  const AssistantMessageBubble({
    super.key,
    required this.message,
    this.onAccurateTap,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant Identity Tag
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.onPrimary,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'OmniDoc AI',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '· Synthesis Complete',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Message Body Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (message.synthesisPoints.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final point in message.synthesisPoints) ...[
                    _buildSynthesisPoint(point),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),

          // Citations Box
          if (message.citations.isNotEmpty) ...[
            const SizedBox(height: 8),
            GroundingCitationCard(
              citations: message.citations,
              onInspectTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Grounding Evidence inspector...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],

          // Quick Feedback Action Pill
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              children: [
                _buildActionItem(
                  icon: Icons.content_copy,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildActionItem(
                  icon: Icons.thumb_up_outlined,
                  label: message.isAccurateFeedbackGiven
                      ? 'Helpful'
                      : 'Accurate',
                  textColor: message.isAccurateFeedbackGiven
                      ? AppColors.secondary
                      : null,
                  onTap: onAccurateTap ?? () {},
                ),
                _buildDivider(),
                _buildActionItem(
                  icon: Icons.share_outlined,
                  label: 'Export memo',
                  onTap: onExportTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exporting executive memo...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesisPoint(SynthesisPoint point) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${point.number}',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: '${point.title}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
                _buildHighlightedDescription(
                  point.description,
                  point.highlight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _buildHighlightedDescription(String description, String? highlight) {
    if (highlight == null || !description.contains(highlight)) {
      return TextSpan(text: description);
    }

    final parts = description.split(highlight);
    return TextSpan(
      children: [
        TextSpan(text: parts[0]),
        TextSpan(
          text: highlight,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (parts.length > 1) TextSpan(text: parts[1]),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: textColor ?? AppColors.outline,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: textColor ?? AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '|',
        style: TextStyle(
          color: AppColors.outlineVariant,
          fontSize: 12,
        ),
      ),
    );
  }
}
