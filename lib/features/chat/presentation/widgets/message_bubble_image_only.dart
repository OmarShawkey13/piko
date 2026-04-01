import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';
import 'package:piko/features/chat/presentation/widgets/message_time_and_status.dart';

class MessageBubbleImageOnly extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final BorderRadius radius;

  const MessageBubbleImageOnly({
    super.key,
    required this.msg,
    required this.isMe,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            MediaMessage(
              imageUrl: msg.imageUrl,
              fileSize: msg.fileSize,
              messageId: msg.id,
              isUploading: msg.isUploading,
              localPath: msg.localPath,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    ColorsManager.black.withValues(alpha: 0.3),
                    BlendMode.srcOver,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: MessageTimeAndStatus(
                      timestamp: msg.timestamp,
                      isMe: isMe,
                      seen: msg.seen,
                      isUploading: msg.isUploading,
                      onImage: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
