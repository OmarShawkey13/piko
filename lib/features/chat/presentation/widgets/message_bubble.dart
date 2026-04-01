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
                      : Colors.transparent,
                ),
                child: _BubbleLayout(
                  isMe: widget.isMe,
                  child: _BubbleContent(
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
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
                style: const TextStyle(color: Colors.red),
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

class _BubbleLayout extends StatelessWidget {
  final bool isMe;
  final Widget child;

  const _BubbleLayout({required this.isMe, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: child,
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final bool isImageOnly;
  final void Function(String)? onReplyTap;

  const _BubbleContent({
    required this.msg,
    required this.isMe,
    required this.isImageOnly,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(isMe ? 22 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 22),
    );

    if (isImageOnly) {
      return _ImageOnlyBubble(msg: msg, isMe: isMe, radius: radius);
    }

    return Container(
      decoration: BoxDecoration(
        color: isMe ? ColorsManager.primary : ColorsManager.bubbleOther,
        borderRadius: radius,
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.replyToId != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: ReplyPreview(
                senderName: msg.replySenderName,
                text: msg.replyText,
                isMe: isMe,
                onTap: () => onReplyTap?.call(msg.replyToId!),
              ),
            ),
          if (msg.imageUrl != null || msg.localPath != null)
            _MessageMedia(msg: msg),
          if (msg.text.trim().isNotEmpty)
            _MessageText(text: msg.text, isMe: isMe),
          _MessageFooter(msg: msg, isMe: isMe),
        ],
      ),
    );
  }
}

class _ImageOnlyBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final BorderRadius radius;

  const _ImageOnlyBubble({
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
            color: Colors.black.withValues(alpha: 0.1),
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
                    Colors.black.withValues(alpha: 0.3),
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

class _MessageMedia extends StatelessWidget {
  final MessageModel msg;

  const _MessageMedia({required this.msg});

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

class _MessageText extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageText({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: ExpandableEmojiText(
        text: text,
        style: TextStylesManager.regular16.copyWith(
          color: isMe ? Colors.white : ColorsManager.bubbleOtherText,
          height: 1.35,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MessageFooter extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const _MessageFooter({required this.msg, required this.isMe});

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
