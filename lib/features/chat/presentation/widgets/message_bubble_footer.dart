import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/features/chat/presentation/widgets/message_time_and_status.dart';

class MessageBubbleFooter extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const MessageBubbleFooter({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 10, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MessageTimeAndStatus(
            timestamp: msg.timestamp,
            isMe: isMe,
            seen: msg.seen,
            isUploading: msg.isUploading,
          ),
        ],
      ),
    );
  }
}
