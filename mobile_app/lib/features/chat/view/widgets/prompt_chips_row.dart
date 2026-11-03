import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PromptChipsRow extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptTap;

  const PromptChipsRow({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: prompts.map((prompt) {
          final icon = _getIconForPrompt(prompt);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onPromptTap(prompt),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prompt,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForPrompt(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('summarize')) {
      return Icons.summarize_outlined;
    } else if (lower.contains('action') || lower.contains('extract')) {
      return Icons.checklist_outlined;
    } else if (lower.contains('compare')) {
      return Icons.compare_arrows;
    }
    return Icons.auto_awesome;
  }
}
