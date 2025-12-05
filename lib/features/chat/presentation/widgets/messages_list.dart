import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble.dart';

class MessagesList extends StatelessWidget {
  final String myId;
  final String otherId;

  const MessagesList({super.key, required this.myId, required this.otherId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: homeCubit.getMessagesStream(myId, otherId),
      builder: (_, snap) {
        if (!snap.hasData) return const LoadingIndicator();
        final messages = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          reverse: true,
          itemBuilder: (_, index) {
            final msg = messages[messages.length - 1 - index];
            final isMe = msg.senderId == myId;
            if (!msg.seen && !isMe) {
              homeCubit.markAllMessagesAsSeen(myId, otherId, msg.id);
            }
            return MessageBubble(msg: msg, isMe: isMe);
          },
        );
      },
    );
  }
}
