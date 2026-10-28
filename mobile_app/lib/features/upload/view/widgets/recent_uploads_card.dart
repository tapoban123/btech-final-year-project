import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../repository/models/upload_item.dart';

class RecentUploadsCard extends StatelessWidget {
  final List<UploadItem> uploads;
  final ValueChanged<String>? onRemoveItem;
  final ValueChanged<UploadItem>? onPreviewItem;

  const RecentUploadsCard({
    super.key,
    required this.uploads,
    this.onRemoveItem,
    this.onPreviewItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Recent Uploads',
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (uploads.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${uploads.length} selected',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
    return InkWell(
      key: Key('upload_item_${item.id}'),
      onTap: onPreviewItem != null ? () => onPreviewItem!(item) : null,
      child: Padding(
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

          // Status & Delete action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIndicator(item.status),
              if (onRemoveItem != null &&
                  item.status != UploadProcessingStatus.processing) ...[
                const SizedBox(width: 6),
                IconButton(
                  key: Key('delete_upload_${item.id}'),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.outline,
                  ),
                  tooltip: 'Remove file',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: () => onRemoveItem!(item.id),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStatusIndicator(UploadProcessingStatus status) {
    switch (status) {
      case UploadProcessingStatus.queued:
        return const SizedBox.shrink();
      case UploadProcessingStatus.processing:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
      case UploadProcessingStatus.completed:
        return const Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.secondary,
        );
      case UploadProcessingStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 20,
          color: AppColors.error,
        );
    }
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
