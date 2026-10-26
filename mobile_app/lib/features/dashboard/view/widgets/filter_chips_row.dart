import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../repository/models/document_item.dart';

class FilterChipsRow extends StatelessWidget {
  final DocumentFilterCategory selectedCategory;
  final ValueChanged<DocumentFilterCategory> onSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      _FilterOption(
        category: DocumentFilterCategory.all,
        label: 'All',
        icon: Icons.check,
      ),
      _FilterOption(
        category: DocumentFilterCategory.reports,
        label: 'Documents',
        icon: Icons.picture_as_pdf_outlined,
      ),
      _FilterOption(
        category: DocumentFilterCategory.recordings,
        label: 'Recordings',
        icon: Icons.graphic_eq,
      ),
      _FilterOption(
        category: DocumentFilterCategory.diagrams,
        label: 'Images',
        icon: Icons.image_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: chips.map((option) {
          final isSelected = selectedCategory == option.category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onSelected(option.category),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.surfaceContainerLowest
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.done : option.icon,
                      size: isSelected ? 14 : 16,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option.label,
                      style: AppTypography.labelMd.copyWith(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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
}

class _FilterOption {
  final DocumentFilterCategory category;
  final String label;
  final IconData icon;

  const _FilterOption({
    required this.category,
    required this.label,
    required this.icon,
  });
}
