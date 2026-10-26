import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../repository/models/chat_message.dart';

class UserMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const UserMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bubble Box
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: Text(
              message.content,
              style: AppTypography.bodyMd.copyWith(
                color: const Color(0xFF1E293B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Timestamp & Read Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.timestamp,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.done_all,
                size: 14,
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
