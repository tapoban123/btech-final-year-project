import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../repository/models/document_item.dart';

class DocumentCard extends StatelessWidget {
  final DocumentItem item;
  final VoidCallback onToggleSelect;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final bool isSelectionMode;

  const DocumentCard({
    super.key,
    required this.item,
    required this.onToggleSelect,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelectionMode ? onToggleSelect : (onTap ?? onToggleSelect),
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: item.isSelected
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.isSelected && isSelectionMode
                ? AppColors.secondary
                : AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator (only when selection mode is enabled)
            if (isSelectionMode) ...[
              _buildSelectionCircle(),
              const SizedBox(width: 12),
            ],

            // Document Type Icon Badge (40x40)

            _buildIconBadge(),
            const SizedBox(width: 12),

            // Title & Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.primary,
                      fontWeight:
                          item.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _buildMetadataRow(),
                ],
              ),
            ),

            // More Options (Kebab Menu)
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: onMoreTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCircle() {
    if (item.isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: AppColors.surfaceContainerLowest,
          size: 13,
        ),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerLowest,
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    final IconData icon;
    final Color iconColor;
    final Color bgColor;
    final Color borderColor;

    switch (item.type) {
      case DocumentType.pdf:
        icon = Icons.picture_as_pdf_outlined;
        iconColor = AppColors.error;
        bgColor = AppColors.pdfBg;
        borderColor = AppColors.outlineVariant;
        break;
      case DocumentType.image:
        icon = Icons.image_outlined;
        iconColor = AppColors.primary;
        bgColor = AppColors.imageBg;
        borderColor = AppColors.outlineVariant;
        break;
      case DocumentType.audio:
        icon = Icons.graphic_eq;
        iconColor = AppColors.secondary;
        bgColor = AppColors.audioBg;
        borderColor = AppColors.secondary.withValues(alpha: 0.3);
        break;
      case DocumentType.docx:
        icon = Icons.description_outlined;
        iconColor = AppColors.primary;
        bgColor = AppColors.docBg;
        borderColor = AppColors.outlineVariant;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: iconColor,
      ),
    );
  }

  Widget _buildMetadataRow() {
    final isAudio = item.type == DocumentType.audio;

    return Row(
      children: [
        // Size or duration
        Text(
          isAudio && item.duration != null ? item.duration! : item.fileSize,
          style: AppTypography.labelSm.copyWith(
            color: isAudio ? AppColors.secondary : AppColors.outline,
            fontWeight: isAudio ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(width: 6),
        const Text('•', style: TextStyle(color: AppColors.outline, fontSize: 10)),
        const SizedBox(width: 6),
        Text(
          item.date,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}

