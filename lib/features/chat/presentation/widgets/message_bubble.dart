import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/expandable_emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/features/chat/data/model/context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/message_time_and_status.dart';
import 'package:piko/features/chat/presentation/widgets/reply_indicator.dart';
import 'package:piko/features/chat/presentation/widgets/reply_preview.dart';
import 'package:piko/features/chat/presentation/widgets/ios_style_context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';
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
      if (mounted) {
        setState(() => _isHighlighted = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isImageOnly =
        (widget.msg.imageUrl != null || widget.msg.localPath != null) &&
        widget.msg.text.trim().isEmpty &&
        widget.msg.replyToId == null;

    return GestureDetector(
      onHorizontalDragUpdate: widget.allowSwipe
          ? _onHorizontalDragUpdate
          : null,
      onHorizontalDragEnd: widget.allowSwipe ? _onHorizontalDragEnd : null,
      onLongPress: () => _showIosContextMenu(context),
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
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: _isHighlighted
                    ? ColorsManager.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: _buildBubbleWrapper(context, isImageOnly),
            ),
          ),
        ],
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
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

  Widget _buildBubbleWrapper(BuildContext context, bool isImageOnly) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: widget.isMe
          ? const Radius.circular(16)
          : const Radius.circular(4),
      bottomRight: widget.isMe
          ? const Radius.circular(4)
          : const Radius.circular(16),
    );

    final bool isReply = widget.msg.replyToId != null;

    final Widget bubbleBody = Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: widget.isMe ? ColorsManager.bubbleMe : ColorsManager.bubbleOther,
        borderRadius: radius,
      ),
      child: _buildBubbleContent(isImageOnly, radius),
    );

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: isReply ? bubbleBody : IntrinsicWidth(child: bubbleBody),
      ),
    );
  }

  Widget _buildBubbleContent(bool isImageOnly, BorderRadius radius) {
    if (isImageOnly) {
      return _buildImageOnlyContent(radius);
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.msg.replyToId != null)
            ReplyPreview(
              senderName: widget.msg.replySenderName,
              text: widget.msg.replyText,
              isMe: widget.isMe,
              onTap: () => widget.onReplyTap?.call(widget.msg.replyToId!),
            ),
          if (widget.msg.imageUrl != null || widget.msg.localPath != null)
            _buildMediaContent(),
          if (widget.msg.text.trim().isNotEmpty) _buildTextContent(),
          Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 2, left: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: MessageTimeAndStatus(
                timestamp: widget.msg.timestamp,
                isMe: widget.isMe,
                seen: widget.msg.seen,
                isUploading: widget.msg.isUploading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOnlyContent(BorderRadius radius) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: MediaMessage(
            imageUrl: widget.msg.imageUrl,
            fileSize: widget.msg.fileSize,
            messageId: widget.msg.id,
            isUploading: widget.msg.isUploading,
            localPath: widget.msg.localPath,
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: MessageTimeAndStatus(
              timestamp: widget.msg.timestamp,
              isMe: widget.isMe,
              seen: widget.msg.seen,
              isUploading: widget.msg.isUploading,
              onImage: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MediaMessage(
          imageUrl: widget.msg.imageUrl,
          fileSize: widget.msg.fileSize,
          messageId: widget.msg.id,
          isUploading: widget.msg.isUploading,
          localPath: widget.msg.localPath,
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 2),
      child: ExpandableEmojiText(
        text: widget.msg.text,
        style: TextStylesManager.regular16.copyWith(
          color: widget.isMe
              ? ColorsManager.bubbleMeText
              : ColorsManager.bubbleOtherText,
          height: 1.3,
        ),
      ),
    );
  }

  void _showIosContextMenu(BuildContext context) {
    final alignment = widget.isMe ? Alignment.topRight : Alignment.topLeft;
    showDialog<Object>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (_) {
        return IosStyleContextMenu(
          actions: [
            ContextMenuAndroid(
              label: appTranslation().get("reply"),
              icon: Icons.reply,
              onTap: () {
                ChatCubit.get(context).setReplyingMessage(widget.msg);
              },
            ),
            ContextMenuAndroid(
              label: appTranslation().get("copy"),
              icon: Icons.copy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.msg.text));
              },
            ),
            ContextMenuAndroid(
              label: appTranslation().get("delete"),
              icon: Icons.delete_outline,
              onTap: () {
                _showDeleteDialog(context);
              },
            ),
          ],
          menuAlignment: alignment,
          child: MessageBubble(
            msg: widget.msg,
            isMe: widget.isMe,
            allowSwipe: false,
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              child: Text(appTranslation().get("delete_for_everyone")),
            ),
          TextButton(
            onPressed: () {
              chatCubit.deleteMessage(
                myId: widget.isMe ? widget.msg.senderId : widget.msg.receiverId,
                otherId: widget.isMe ? widget.msg.receiverId : widget.msg.senderId,
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
