import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble.dart';
import 'package:piko/features/chat/presentation/widgets/typing_indicator.dart';

class MessagesList extends StatefulWidget {
  final String myId;
  final String otherId;
  final double bottomPadding;
  final bool isPreview;

  const MessagesList({
    super.key,
    required this.myId,
    required this.otherId,
    this.bottomPadding = 0,
    this.isPreview = false,
  });

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final Map<String, GlobalKey<MessageBubbleState>> messageKeys = {};

  void scrollToMessage(String messageId) {
    final key = messageKeys[messageId];
    if (key != null) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart,
        );
        // تفعيل الـ highlight بعد السكرول
        key.currentState?.highlight();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    return StreamBuilder<List<MessageModel>>(
      stream: chatCubit.getMessagesStream(widget.myId, widget.otherId),
      builder: (_, snap) {
        if (!snap.hasData) return const LoadingIndicator();
        final messages = snap.data!;

        return ListView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: widget.bottomPadding + 8,
          ),
          itemCount: messages.length + (widget.isPreview ? 0 : 1),
          reverse: true,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: false,
          itemBuilder: (_, index) {
            if (!widget.isPreview && index == 0) {
              return TypingIndicator(
                myId: widget.myId,
                otherId: widget.otherId,
              );
            }

            final msgIndex = widget.isPreview ? messages.length - 1 - index : messages.length - index;
            if (msgIndex < 0 || msgIndex >= messages.length) return const SizedBox();
            
            final msg = messages[msgIndex];
            final isMe = msg.senderId == widget.myId;

            if (!widget.isPreview && !msg.seen && !isMe) {
              chatCubit.markAllMessagesAsSeen(
                widget.myId,
                widget.otherId,
                msg.id,
              );
            }

            final key = messageKeys.putIfAbsent(
              msg.id,
              () => GlobalKey<MessageBubbleState>(),
            );

            return MessageBubble(
              key: key,
              msg: msg,
              isMe: isMe,
              onReplyTap: widget.isPreview ? null : (replyId) => scrollToMessage(replyId),
            );
          },
        );
      },
    );
  }
}
