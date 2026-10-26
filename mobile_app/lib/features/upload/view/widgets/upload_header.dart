import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class UploadHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackTap;
  final VoidCallback? onOptionsTap;

  const UploadHeader({
    super.key,
    required this.onBackTap,
    this.onOptionsTap,
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
              Row(
                children: [
                  InkWell(
                    onTap: onBackTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Knowledge',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onOptionsTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
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
