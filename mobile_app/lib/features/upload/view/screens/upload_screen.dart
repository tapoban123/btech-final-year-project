import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/preview/file_preview_modal.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../blocs/upload_bloc.dart';
import '../../blocs/upload_event.dart';
import '../../blocs/upload_state.dart';
import '../../services/file_picker_service.dart';
import '../widgets/recent_uploads_card.dart';
import '../widgets/upload_action_cards.dart';
import '../widgets/upload_header.dart';
import '../widgets/voice_recording_card.dart';

enum _PickerOption { documents, images, audio }

class UploadScreen extends StatefulWidget {
  final IFilePickerService filePickerService;

  const UploadScreen({
    super.key,
    this.filePickerService = const FilePickerService(),
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UploadBloc>().add(const LoadUploadData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadBloc, UploadState>(
      listenWhen: (prev, curr) =>
          (prev.isUploading && !curr.isUploading) ||
          (curr.status == UploadScreenStatus.failure &&
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage),
      listener: (context, state) {
        if (state.status == UploadScreenStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.recentUploads.length} files uploaded successfully',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state.status == UploadScreenStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Upload failed'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          appBar: UploadHeader(
            onBackTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Action Cards Section (Upload Files & Record Voice Note) - never scrolls
                      UploadActionCards(
                        onUploadFilesTap: () => _handleFileUpload(context),
                        onRecordVoiceTap: () {
                          context
                              .read<UploadBloc>()
                              .add(const OpenVoiceRecorder());
                        },
                      ),
                      const SizedBox(height: 12),

                      // 2. Voice Recording Section (Visible when recorder is open) - never scrolls
                      if (state.isRecorderOpen) ...[
                        VoiceRecordingCard(
                          isRecording: state.isRecording,
                          formattedTime: state.formattedDuration,
                          amplitude: state.currentAmplitude,
                          onRecord: () {
                            context
                                .read<UploadBloc>()
                                .add(const StartVoiceRecording());
                          },
                          onDone: () {
                            context
                                .read<UploadBloc>()
                                .add(const StopAndSaveVoiceRecording());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice Memo saved'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          onDelete: () {
                            context
                                .read<UploadBloc>()
                                .add(const CancelVoiceRecording());
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 3. Recent Uploads Section (only the files scroll inside ListView.builder)
                      Expanded(
                        child: RecentUploadsCard(
                          isExpanded: true,
                          uploads: state.recentUploads,
                          onRemoveItem: (itemId) {
                            context
                                .read<UploadBloc>()
                                .add(RemoveUploadItem(itemId));
                          },
                          onPreviewItem: (item) {
                            FilePreviewModal.show(
                              context,
                              title: item.title,
                              type: item.type,
                              filePath: item.filePath,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            state.recentUploads.isNotEmpty && !state.isUploading
                                ? () {
                                    context
                                        .read<UploadBloc>()
                                        .add(const ConfirmAndUploadAll());
                                  }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          disabledBackgroundColor:
                              AppColors.surfaceContainerLow,
                          disabledForegroundColor: AppColors.outline,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: state.isUploading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                state.recentUploads.isNotEmpty
                                    ? 'Confirm Upload (${state.recentUploads.length})'
                                    : 'Confirm Upload',
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: state.recentUploads.isNotEmpty
                                      ? AppColors.onPrimary
                                      : AppColors.outline,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFileUpload(BuildContext context) async {
    final option = await showModalBottomSheet<_PickerOption>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildPickerOption(
                icon: Icons.description_outlined,
                iconColor: AppColors.primaryContainer,
                title: 'Documents',
                onTap: () => Navigator.of(ctx).pop(_PickerOption.documents),
              ),
              const SizedBox(height: 12),
              _buildPickerOption(
                icon: Icons.image_outlined,
                iconColor: AppColors.secondary,
                title: 'Images',
                onTap: () => Navigator.of(ctx).pop(_PickerOption.images),
              ),
              const SizedBox(height: 12),
              _buildPickerOption(
                icon: Icons.audio_file_outlined,
                iconColor: AppColors.primary,
                title: 'Audio',
                onTap: () => Navigator.of(ctx).pop(_PickerOption.audio),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || option == null) return;

    // Wait for the modal dismissal transition to complete before presenting the native iOS picker
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    switch (option) {
      case _PickerOption.documents:
        await _pickAndUploadFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        );
        break;
      case _PickerOption.images:
        await _pickAndUploadFiles(type: FileType.image);
        break;
      case _PickerOption.audio:
        await _pickAndUploadFiles(type: FileType.audio);
        break;
    }
  }

  Widget _buildPickerOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final files = await widget.filePickerService.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (files != null && files.isNotEmpty && mounted) {
        final selectedFiles = files.map((file) {
          final ext = file.extension ?? file.name.split('.').last;
          final docType = _getDocumentTypeFromExtension(ext);
          return SelectedFileInfo(
            filename: file.name,
            type: docType,
            filePath: file.path,
            fileSize: file.lengthSync(),
          );
        }).toList();

        context.read<UploadBloc>().add(
              TriggerMultipleFilesUpload(selectedFiles),
            );

        final count = files.length;
        final message = count == 1
            ? '${files.first.name} selected'
            : '$count files selected';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage or media permission is required to select files.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  DocumentType _getDocumentTypeFromExtension(String ext) {
    final clean = ext.toLowerCase().replaceAll('.', '');
    switch (clean) {
      case 'pdf':
        return DocumentType.pdf;
      case 'doc':
      case 'docx':
      case 'txt':
        return DocumentType.docx;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return DocumentType.image;
      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'aac':
        return DocumentType.audio;
      default:
        return DocumentType.pdf;
    }
  }
}
