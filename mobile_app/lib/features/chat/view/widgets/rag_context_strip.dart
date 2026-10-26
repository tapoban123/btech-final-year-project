import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../repository/models/chat_message.dart';

class RAGContextStrip extends StatelessWidget {
  final List<ActiveRAGContext> activeContexts;
  final bool isGrounded;
  final VoidCallback? onContextTap;

  const RAGContextStrip({
    super.key,
    required this.activeContexts,
    this.isGrounded = true,
    this.onContextTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onContextTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left cluster: mini document badges & count label
            Row(
              children: [
                // Mini badges
                Row(
                  children: activeContexts.take(3).map((ctx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _getIconForType(ctx.type),
                          size: 14,
                          color: ctx.type == DocumentType.audio
                              ? AppColors.secondary
                              : AppColors.primaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 6),

                // Label
                Text(
                  '${AppFormatters.formatNumber(activeContexts.length)} Active Contexts',
                  style: AppTypography.titleSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.expand_more,
                  size: 16,
                  color: AppColors.outline,
                ),
              ],
            ),

            // Right: Grounded Status Badge
            if (isGrounded)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Grounded',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentType.image:
        return Icons.image_outlined;
      case DocumentType.audio:
        return Icons.graphic_eq;
      case DocumentType.docx:
        return Icons.description_outlined;
    }
  }
}
