import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackTap;
  final VoidCallback? onManageTap;

  const ChatHeader({
    super.key,
    required this.onBackTap,
    this.onManageTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button & OmniDoc Brand
              Row(
                children: [
                  InkWell(
                    onTap: onBackTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryContainer,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OmniDoc',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              // Right-side Manage button
              InkWell(
                onTap: onManageTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
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
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.tune,
                        size: 16,
                        color: AppColors.primaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
