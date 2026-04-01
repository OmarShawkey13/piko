import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_image_only.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_media.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_text.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_footer.dart';
import 'package:piko/features/chat/presentation/widgets/reply_preview.dart';

class MessageBubbleContent extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final bool isImageOnly;
  final void Function(String)? onReplyTap;

  const MessageBubbleContent({
    super.key,
    required this.msg,
    required this.isMe,
    required this.isImageOnly,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(isMe ? 22 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 22),
    );

    if (isImageOnly) {
      return MessageBubbleImageOnly(msg: msg, isMe: isMe, radius: radius);
    }

    return Container(
      decoration: BoxDecoration(
        color: isMe ? ColorsManager.primary : ColorsManager.bubbleOther,
        borderRadius: radius,
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.replyToId != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: ReplyPreview(
                senderName: msg.replySenderName,
                text: msg.replyText,
                isMe: isMe,
                onTap: () => onReplyTap?.call(msg.replyToId!),
              ),
            ),
          if (msg.imageUrl != null || msg.localPath != null)
            MessageBubbleMedia(msg: msg),
          if (msg.text.trim().isNotEmpty)
            MessageBubbleText(text: msg.text, isMe: isMe),
          MessageBubbleFooter(msg: msg, isMe: isMe),
        ],
      ),
    );
  }
}
