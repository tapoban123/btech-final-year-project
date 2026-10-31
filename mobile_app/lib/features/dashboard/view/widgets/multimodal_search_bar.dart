import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MultimodalSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onVoiceQueryTap;
  final String hintText;

  const MultimodalSearchBar({
    super.key,
    this.onTap,
    this.onVoiceQueryTap,
    this.hintText = 'Search across all documents, images, and voice...',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search,
              color: AppColors.outline,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hintText,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.outline,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.mic_none_outlined,
                color: AppColors.outline,
                size: 20,
              ),
              splashRadius: 20,
              tooltip: 'Voice Search',
              onPressed: onVoiceQueryTap ?? onTap,
            ),
          ],
        ),
      ),
    );
  }
}
