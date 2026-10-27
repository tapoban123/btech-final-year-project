import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../repository/models/upload_item.dart';

class RecentUploadsCard extends StatelessWidget {
  final List<UploadItem> uploads;

  const RecentUploadsCard({
    super.key,
    required this.uploads,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = uploads
        .where((u) => u.status == UploadProcessingStatus.processing)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Uploads',
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${AppFormatters.formatNumber(activeCount)} Active',
              style: AppTypography.labelSm.copyWith(
                color: activeCount > 0 ? AppColors.secondary : AppColors.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List Container or Empty State
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1.0,
            ),
          ),
          child: uploads.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 38,
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No uploads yet',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload docs, images, or audio to stage them here',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.outline.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: uploads.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final item = uploads[index];
                    return _buildUploadRow(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUploadRow(UploadItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getIconForType(item.type),
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Stage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.stageDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Processing Status Pill / Spinner
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: 0.75,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Processing...',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
        return Icons.audio_file_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
    }
  }
}
