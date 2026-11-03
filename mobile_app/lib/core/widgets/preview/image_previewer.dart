import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ImagePreviewer extends StatelessWidget {
  final String? filePath;
  final String title;

  const ImagePreviewer({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final fileExists = filePath != null && File(filePath!).existsSync();

    if (!fileExists) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Image preview is unavailable (file path not found)',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      constraints: const BoxConstraints(maxHeight: 500, minHeight: 280),
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            File(filePath!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to load image',
                    style: AppTypography.bodySm.copyWith(color: Colors.white70),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
