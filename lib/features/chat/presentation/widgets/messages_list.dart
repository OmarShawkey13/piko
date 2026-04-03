import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
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
    return BlocListener<ChatCubit, ChatStates>(
      listenWhen: (_, state) => state is ChatSearchResultsUpdatedState,
      listener: (context, state) {
        if (state is ChatSearchResultsUpdatedState &&
            state.resultIds.isNotEmpty &&
            state.currentIndex >= 0) {
          scrollToMessage(state.resultIds[state.currentIndex]);
        }
      },
      child: StreamBuilder<List<MessageModel>>(
        stream: chatCubit.getMessagesStream(widget.myId, widget.otherId),
        builder: (_, snap) {
          if (snap.hasData) {
            chatCubit.updateCurrentMessages(snap.data!);
          }
          return ConditionalBuilder(
            loadingState: !snap.hasData,
            emptyState: snap.hasData && snap.data!.isEmpty,
            emptyBuilder: (context) => const Center(
              child: Text(
                'لا توجد رسائل بعد.. ابدأ المحادثة الآن!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            successBuilder: (_) {
              final messages = snap.data!;
              // تجميع الصور المتتالية
              final List<dynamic> displayItems = [];
              for (int i = 0; i < messages.length; i++) {
                final msg = messages[i];
                if (msg.imageUrl != null &&
                    msg.text.trim().isEmpty &&
                    msg.replyToId == null) {
                  if (displayItems.isNotEmpty &&
                      displayItems.last is List<MessageModel> &&
                      (displayItems.last as List<MessageModel>)
                              .first
                              .senderId ==
                          msg.senderId) {
                    (displayItems.last as List<MessageModel>).add(msg);
                  } else {
                    displayItems.add([msg]);
                  }
                } else {
                  displayItems.add(msg);
                }
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: widget.bottomPadding + 8,
                ),
                itemCount: displayItems.length + (widget.isPreview ? 0 : 1),
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

                  final itemIndex = widget.isPreview
                      ? displayItems.length - 1 - index
                      : displayItems.length - index;
                  if (itemIndex < 0 || itemIndex >= displayItems.length) {
                    return const SizedBox();
                  }

                  final item = displayItems[itemIndex];
                  final MessageModel firstMsg = item is List<MessageModel>
                      ? item.first
                      : item as MessageModel;
                  final isMe = firstMsg.senderId == widget.myId;

                  if (item is List<MessageModel>) {
                    // مجموعة صور
                    return MessageBubble(
                      key: ValueKey(item.first.id),
                      msg: item.first,
                      // نمرر الأولى كمرجع مؤقت
                      imageGroup: item,
                      isMe: isMe,
                      onReplyTap: widget.isPreview
                          ? null
                          : (replyId) => scrollToMessage(replyId),
                    );
                  }

                  final msg = item as MessageModel;
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
                    onReplyTap: widget.isPreview
                        ? null
                        : (replyId) => scrollToMessage(replyId),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
