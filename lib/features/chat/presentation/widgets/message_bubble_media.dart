import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_image_group.dart';

class MessageBubbleMedia extends StatelessWidget {
  final MessageModel msg;
  final List<MessageModel>? imageGroup;

  const MessageBubbleMedia({super.key, required this.msg, this.imageGroup});

  @override
  Widget build(BuildContext context) {
    if (imageGroup != null && imageGroup!.length > 1) {
      return MessageBubbleImageGroup(
        images: imageGroup!,
        isMe: false, // سيتم تحديد الـ radius من الـ parent
        radius: BorderRadius.circular(18),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: MediaMessage(
          imageUrl: msg.imageUrl,
          fileSize: msg.fileSize,
          messageId: msg.id,
          isUploading: msg.isUploading,
          localPath: msg.localPath,
        ),
      ),
    );
  }
}
