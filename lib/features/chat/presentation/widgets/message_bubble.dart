import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/features/chat/data/model/context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/reply_indicator.dart';
import 'package:piko/features/chat/presentation/widgets/ios_style_context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/bubble_layout.dart';
import 'package:piko/features/chat/presentation/widgets/message_bubble_content.dart';
import 'package:piko/core/utils/constants/constants.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel msg;
  final bool isMe;
  final bool allowSwipe;
  final void Function(String messageId)? onReplyTap;

  const MessageBubble({
    super.key,
    required this.msg,
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
    if (!widget.allowSwipe) return;
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
    final bool hasMedia =
        widget.msg.imageUrl != null || widget.msg.localPath != null;
    final bool hasText = widget.msg.text.trim().isNotEmpty;
    final bool isImageOnly =
        hasMedia && !hasText && widget.msg.replyToId == null;
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onLongPress: () => _showIosContextMenu(context),
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
                  color: _isHighlighted
                      ? ColorsManager.primary.withValues(alpha: 0.1)
                      : ColorsManager.transparent,
                ),
                child: BubbleLayout(
                  isMe: widget.isMe,
                  child: MessageBubbleContent(
                    msg: widget.msg,
                    isMe: widget.isMe,
                    isImageOnly: isImageOnly,
                    onReplyTap: widget.onReplyTap,
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
    final alignment = widget.isMe ? Alignment.topRight : Alignment.topLeft;
    showDialog<Object>(
      context: context,
      barrierColor: ColorsManager.black.withValues(alpha: 0.3),
      builder: (_) => IosStyleContextMenu(
        actions: [
          ContextMenuAndroid(
            label: appTranslation().get("reply"),
            icon: Icons.reply_rounded,
            onTap: () => ChatCubit.get(context).setReplyingMessage(widget.msg),
          ),
          ContextMenuAndroid(
            label: appTranslation().get("copy"),
            icon: Icons.copy_rounded,
            onTap: () =>
                Clipboard.setData(ClipboardData(text: widget.msg.text)),
          ),
          ContextMenuAndroid(
            label: appTranslation().get("delete"),
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () => _showDeleteDialog(context),
          ),
        ],
        menuAlignment: alignment,
        child: MessageBubble(
          msg: widget.msg,
          isMe: widget.isMe,
          allowSwipe: false,
        ),
      ),
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
