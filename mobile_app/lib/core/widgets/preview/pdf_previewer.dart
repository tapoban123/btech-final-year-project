import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PdfPreviewer extends StatefulWidget {
  final String? filePath;
  final String title;

  const PdfPreviewer({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfPreviewer> createState() => _PdfPreviewerState();
}

class _PdfPreviewerState extends State<PdfPreviewer> {
  PdfController? _pdfController;
  int _pageCount = 0;
  int _currentPage = 1;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    if (widget.filePath == null || !File(widget.filePath!).existsSync()) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'PDF file path not found';
        });
      }
      return;
    }

    try {
      final docFuture = PdfDocument.openFile(widget.filePath!);
      _pdfController = PdfController(document: docFuture);
      final doc = await docFuture;
      if (mounted) {
        setState(() {
          _pageCount = doc.pagesCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load PDF preview';
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null || _pdfController == null) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 28,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Unable to display PDF preview',
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
      constraints: const BoxConstraints(maxHeight: 520, minHeight: 300),
      color: AppColors.surfaceContainerLowest,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PdfView(
            controller: _pdfController!,
            scrollDirection: Axis.vertical,
            onPageChanged: (page) {
              if (mounted) {
                setState(() => _currentPage = page);
              }
            },
          ),
          if (_pageCount > 0)
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Page $_currentPage of $_pageCount',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
