import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
            // Left: Icon & Clean Count
            Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  size: 18,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '${AppFormatters.formatNumber(activeContexts.length)} Active Contexts',
                  style: AppTypography.titleSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),

            // Right: Clean Manage Button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Manage',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.tune,
                    size: 14,
                    color: AppColors.primaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
