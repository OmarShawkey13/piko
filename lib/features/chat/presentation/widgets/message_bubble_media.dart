import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';

class MessageBubbleMedia extends StatelessWidget {
  final MessageModel msg;

  const MessageBubbleMedia({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
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
