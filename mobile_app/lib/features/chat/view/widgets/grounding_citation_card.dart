import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../repository/models/chat_message.dart';

class GroundingCitationCard extends StatelessWidget {
  final List<CitationItem> citations;
  final VoidCallback? onInspectTap;

  const GroundingCitationCard({
    super.key,
    required this.citations,
    this.onInspectTap,
  });

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.description,
              size: 16,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GROUNDING EVIDENCE',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),

                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (int i = 0; i < citations.length; i++) ...[
                      _buildCitationTag(citations[i]),
                      if (i < citations.length - 1)
                        Text(
                          '&',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          InkWell(
            onTap: onInspectTap,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(
                Icons.open_in_new,
                size: 16,
                color: AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationTag(CitationItem citation) {
    final isAudio = citation.type == DocumentType.audio;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      constraints: const BoxConstraints(maxWidth: 150),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAudio ? Icons.graphic_eq : Icons.picture_as_pdf_outlined,
            size: 12,
            color: isAudio ? AppColors.secondary : AppColors.primaryContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              citation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${citation.reference})',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
