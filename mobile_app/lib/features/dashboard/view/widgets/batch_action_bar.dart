import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';

class BatchActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onChatTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCloseTap;

  // Backward compatibility aliases
  final VoidCallback? onQueryTap;
  final VoidCallback? onExportTap;

  const BatchActionBar({
    super.key,
    required this.selectedCount,
    this.onChatTap,
    this.onShareTap,
    this.onDeleteTap,
    this.onCloseTap,
    this.onQueryTap,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChat = onChatTap ?? onQueryTap;
    final effectiveShare = onShareTap ?? onExportTap;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Close button and selection count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onCloseTap != null) ...[
                    InkWell(
                      onTap: onCloseTap,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    selectedCount > 0
                        ? '${AppFormatters.formatNumber(selectedCount)} selected'
                        : 'Select items',
                    style: AppTypography.titleSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Right: Action buttons cluster (Chat, Share, Delete)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.forum_outlined,
                    label: 'Chat',
                    onTap: selectedCount > 0 ? effectiveChat : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: selectedCount > 0 ? effectiveShare : null,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: AppColors.error,
                    onTap: selectedCount > 0 ? onDeleteTap : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        onTap == null ? AppColors.outline.withValues(alpha: 0.5) : (color ?? AppColors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: effectiveColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
