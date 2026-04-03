import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/features/chat/data/model/context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/reply_indicator.dart';
import 'package:piko/features/chat/presentation/widgets/ios_style_context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/bubble_layout.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_content.dart';
import 'package:piko/features/chat/presentation/widgets/message_details_sheet.dart';
import 'package:piko/core/utils/constants/constants.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel msg;
  final List<MessageModel>? imageGroup;
  final bool isMe;
  final bool allowSwipe;
  final void Function(String messageId)? onReplyTap;

  const MessageBubble({
    super.key,
    required this.msg,
    this.imageGroup,
    required this.isMe,
    this.allowSwipe = true,
    this.onReplyTap,
  });

  @override
  State<MessageBubble> createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  double _dragOffset = 0.0;
  bool _isReplyTriggered = false;
  bool _isHighlighted = false;

  void highlight() {
    setState(() => _isHighlighted = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isHighlighted = false);
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.allowSwipe || ChatCubit.get(context).isSelectionMode) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 80.0);
      if (_dragOffset >= 50 && !_isReplyTriggered) {
        _isReplyTriggered = true;
        HapticFeedback.lightImpact();
      } else if (_dragOffset < 50) {
        _isReplyTriggered = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isReplyTriggered) {
      ChatCubit.get(context).setReplyingMessage(widget.msg);
    }
    setState(() {
      _dragOffset = 0;
      _isReplyTriggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    final isSelected = chatCubit.selectedMessages.any(
      (m) => m.id == widget.msg.id,
    );

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onLongPress: () =>
          !chatCubit.isSelectionMode ? _showIosContextMenu(context) : null,
      onTap: () => chatCubit.isSelectionMode
          ? chatCubit.toggleMessageSelection(widget.msg)
          : null,
      child: RepaintBoundary(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            ReplyIndicator(
              dragOffset: _dragOffset,
              isReplyTriggered: _isReplyTriggered,
            ),
            Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorsManager.primary.withValues(alpha: 0.2)
                      : (_isHighlighted
                            ? ColorsManager.primary.withValues(alpha: 0.1)
                            : ColorsManager.transparent),
                ),
                child: BubbleLayout(
                  isMe: widget.isMe,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chatCubit.isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: ColorsManager.primary,
                            size: 20,
                          ),
                        ),
                      Flexible(
                        child: MessageBubbleContent(
                          msg: widget.msg,
                          imageGroup: widget.imageGroup,
                          isMe: widget.isMe,
                          isImageOnly:
                              widget.msg.imageUrl != null &&
                              widget.msg.text.trim().isEmpty &&
                              widget.msg.replyToId == null,
                          onReplyTap: widget.onReplyTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIosContextMenu(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    showDialog<Object>(
      context: context,
      barrierColor: ColorsManager.black.withValues(alpha: 0.3),
      builder: (dialogContext) => BlocProvider.value(
        value: chatCubit,
        child: IosStyleContextMenu(
          actions: [
            ContextMenuAndroid(
              label: appTranslation().get("reply"),
              icon: Icons.reply_rounded,
              onTap: () => chatCubit.setReplyingMessage(widget.msg),
            ),
            ContextMenuAndroid(
              label: appTranslation().get("copy"),
              icon: Icons.copy_rounded,
              onTap: () =>
                  Clipboard.setData(ClipboardData(text: widget.msg.text)),
            ),
            ContextMenuAndroid(
              label: appTranslation().get("select"),
              icon: Icons.check_circle_outline_rounded,
              onTap: () =>
                  chatCubit.toggleSelectionMode(initialMessage: widget.msg),
            ),
            ContextMenuAndroid(
              label: appTranslation().get("info"),
              icon: Icons.info_outline_rounded,
              onTap: () => _showMessageDetails(context),
            ),
            ContextMenuAndroid(
              label: appTranslation().get("delete"),
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onTap: () => _showDeleteDialog(context),
            ),
          ],
          menuAlignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
          child: MessageBubble(
            msg: widget.msg,
            isMe: widget.isMe,
            allowSwipe: false,
          ),
        ),
      ),
    );
  }

  void _showMessageDetails(BuildContext context) {
    showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => MessageDetailsSheet(msg: widget.msg),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    showDialog<Object>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(appTranslation().get("delete")),
        content: Text(appTranslation().get("delete_message_confirm")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appTranslation().get("cancel")),
          ),
          if (widget.isMe)
            TextButton(
              onPressed: () {
                chatCubit.deleteMessage(
                  myId: widget.msg.senderId,
                  otherId: widget.msg.receiverId,
                  messageId: widget.msg.id,
                  deleteForEveryone: true,
                );
                Navigator.pop(context);
              },
              child: Text(
                appTranslation().get("delete_for_everyone"),
                style: const TextStyle(color: ColorsManager.error),
              ),
            ),
          TextButton(
            onPressed: () {
              chatCubit.deleteMessage(
                myId: widget.isMe ? widget.msg.senderId : widget.msg.receiverId,
                otherId: widget.isMe
                    ? widget.msg.receiverId
                    : widget.msg.senderId,
                messageId: widget.msg.id,
                deleteForEveryone: false,
              );
              Navigator.pop(context);
            },
            child: Text(appTranslation().get("delete_for_me")),
          ),
        ],
      ),
    );
  }
}
