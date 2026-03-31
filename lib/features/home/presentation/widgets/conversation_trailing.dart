import 'package:flutter/material.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class ConversationTrailing extends StatelessWidget {
  final ChatModel chat;

  const ConversationTrailing({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatTime(chat.timestamp),
          style: TextStylesManager.regular12.copyWith(
            color: ColorsManager.textSecondary,
          ),
        ),
        verticalSpace6,
        if (chat.unreadCount > 0)
          Badge.count(
            count: chat.unreadCount,
            textColor: ColorsManager.bubbleMeLightText,
            backgroundColor: ColorsManager.primary,
          ),
      ],
    );
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final period = dt.hour < 12
        ? appTranslation().get("am")
        : appTranslation().get("pm");
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
