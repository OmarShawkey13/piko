import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';

class ReplyPreview extends StatelessWidget {
  final MessageModel? replyingMessage;
  final String? senderName;
  final String? text;
  final bool? isDark;
  final String? myId;
  final String? otherDisplayName;
  final VoidCallback? onTap;
  final bool? isMe;

  const ReplyPreview({
    super.key,
    this.replyingMessage,
    this.isDark,
    this.myId,
    this.otherDisplayName,
    this.senderName,
    this.text,
    this.onTap,
    this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        isDark ?? Theme.of(context).brightness == Brightness.dark;

    // استخراج البيانات بناءً على المصدر
    final String displaySender = replyingMessage != null
        ? (replyingMessage!.senderId == myId ? "You" : otherDisplayName ?? "")
        : (senderName ?? "");

    final String displayText = replyingMessage != null
        ? (replyingMessage!.text.isEmpty ? "Attachment" : replyingMessage!.text)
        : (text ?? "");

    // تحديد الألوان بناءً على الطرف (Me أو Other أو Input)
    final bool isInInput = replyingMessage != null;

    // إذا كنت أنا المرسل (داخل الفقاعة)، نستخدم اللون الأبيض لتناسق الألوان
    final Color accentColor = isInInput
        ? ColorsManager.primary
        : (isMe == true
              ? Colors.white.withValues(alpha: 0.9)
              : ColorsManager.primary);

    final Color bgColor = isInInput
        ? (isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05))
        : (isMe == true
              ? Colors.black.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05));

    final Color textColor = isInInput
        ? (isDarkMode
              ? ColorsManager.darkTextSecondary
              : ColorsManager.lightTextSecondary)
        : (isMe == true
              ? Colors.white.withValues(alpha: 0.7)
              : ColorsManager.lightTextSecondary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isInInput
            ? const EdgeInsets.all(8)
            : const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: accentColor, width: 4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displaySender,
                    style: TextStylesManager.bold12.copyWith(
                      color: accentColor,
                    ),
                  ),
                  Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.regular12.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isInInput)
              IconButton(
                onPressed: () =>
                    ChatCubit.get(context).setReplyingMessage(null),
                icon: const Icon(Icons.close_rounded, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
