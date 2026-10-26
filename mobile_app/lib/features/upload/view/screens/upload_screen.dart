import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../../dashboard/view/widgets/dashboard_bottom_nav.dart';
import '../../blocs/upload_bloc.dart';
import '../../blocs/upload_event.dart';
import '../../blocs/upload_state.dart';
import '../widgets/recent_uploads_card.dart';
import '../widgets/upload_action_cards.dart';
import '../widgets/upload_header.dart';
import '../widgets/voice_recording_card.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

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
    return BlocBuilder<UploadBloc, UploadState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          appBar: UploadHeader(
            onBackTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            onOptionsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload settings & batch preferences'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Action Cards Section (Upload Files & Record Voice Note)
                      UploadActionCards(
                        onUploadFilesTap: () => _handleFileUpload(context),
                        onRecordVoiceTap: () {
                          context
                              .read<UploadBloc>()
                              .add(const StartVoiceRecording());
                        },
                      ),
                      const SizedBox(height: 24),

                      // 2. Recent Uploads Section
                      RecentUploadsCard(uploads: state.recentUploads),
                      const SizedBox(height: 24),

                      // 3. Voice Recording Overlay / Section
                      VoiceRecordingCard(
                        isRecording: state.isRecording,
                        formattedTime: state.formattedDuration,
                        statusMessage: state.speechDetectionMessage,
                        onSaveAndIngest: () {
                          context
                              .read<UploadBloc>()
                              .add(const StopAndSaveVoiceRecording());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Voice Memo saved and queued for OCR/Audio indexing',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: DashboardBottomNav(
            currentIndex: 0,
            onTabSelected: (index) {
              if (index == 0) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } else if (index == 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semantic Search'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else if (index == 2) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  void _handleFileUpload(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                title: const Text('Upload PDF Document'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<UploadBloc>().add(
                        const TriggerFileUpload(
                          filename: 'Annual_Financial_Report.pdf',
                          type: DocumentType.pdf,
                        ),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.primary),
                title: const Text('Upload Image / Diagram'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<UploadBloc>().add(
                        const TriggerFileUpload(
                          filename: 'System_Architecture_Whiteboard.png',
                          type: DocumentType.image,
                        ),
                      );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.audio_file, color: AppColors.secondary),
                title: const Text('Upload Audio Recording'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<UploadBloc>().add(
                        const TriggerFileUpload(
                          filename: 'Interview_Recording.m4a',
                          type: DocumentType.audio,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
