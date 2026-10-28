import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../features/dashboard/repository/models/document_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'audio_previewer.dart';
import 'image_previewer.dart';
import 'pdf_previewer.dart';

class FilePreviewModal extends StatelessWidget {
  final String title;
  final DocumentType type;
  final String? filePath;
  final AudioPlayer? player;

  const FilePreviewModal({
    super.key,
    required this.title,
    required this.type,
    this.filePath,
    this.player,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required DocumentType type,
    String? filePath,
    AudioPlayer? player,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilePreviewModal(
        title: title,
        type: type,
        filePath: filePath,
        player: player,
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
        return Icons.audiotrack_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
    }
  }

  Widget _buildPreviewContent() {
    switch (type) {
      case DocumentType.image:
        return ImagePreviewer(filePath: filePath, title: title);
      case DocumentType.audio:
        return AudioPreviewer(filePath: filePath, title: title, player: player);
      case DocumentType.pdf:
      case DocumentType.docx:
        return PdfPreviewer(filePath: filePath, title: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Preview mode',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('close_preview_modal_button'),
                    icon: const Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),

            // Preview Area
            Flexible(
              child: SingleChildScrollView(
                child: _buildPreviewContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
