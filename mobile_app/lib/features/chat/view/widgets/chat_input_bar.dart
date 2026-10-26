import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final VoidCallback? onVoiceRecordTap;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoiceRecordTap,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Text Input Container with Internal Send Trigger
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onSend(val);
                        controller.clear();
                      }
                    },
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask questions about the selection...',
                      hintStyle: AppTypography.bodyMd.copyWith(
                        color: AppColors.outline,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: isSending
                        ? null
                        : () {
                            final text = controller.text;
                            if (text.trim().isNotEmpty) {
                              onSend(text);
                              controller.clear();
                            }
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: isSending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward,
                              color: AppColors.onPrimary,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Dedicated Mint Green Microphone Button
        InkWell(
          onTap: onVoiceRecordTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.mic,
              color: AppColors.onSecondary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
