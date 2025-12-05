import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/expandable_emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/chat/data/model/context_menu.dart';
import 'package:piko/features/chat/presentation/widgets/image_preview_page.dart';
import 'package:piko/features/chat/presentation/widgets/ios_style_context_menu.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
  });

  String _formatTime(DateTime dt) {
    final period = dt.hour < 12
        ? appTranslation().get('am')
        : appTranslation().get('pm');
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(msg.timestamp);
    final bubbleColor = isMe
        ? homeCubit.isDarkMode
              ? ColorsManager.bubbleMeDark
              : ColorsManager.bubbleMeLight
        : homeCubit.isDarkMode
        ? ColorsManager.bubbleOtherDark
        : ColorsManager.bubbleOtherLight;
    final textColor = isMe
        ? homeCubit.isDarkMode
              ? ColorsManager.bubbleMeDarkText
              : ColorsManager.bubbleMeLightText
        : homeCubit.isDarkMode
        ? ColorsManager.bubbleOtherDarkText
        : ColorsManager.bubbleOtherLightText;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        _showIosContextMenu(context);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              boxShadow: isMe
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 220, // ⬅️ عرض ثابت شبه واتساب
                        minWidth: 120, // ⬅️ اختياري لكنه يخليها أجمل
                        maxHeight: 350, // ⬅️ لو الصورة طويلة قوي
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder<Object>(
                              transitionDuration: const Duration(
                                milliseconds: 250,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 250,
                              ),
                              pageBuilder: (_, _, _) =>
                                  ImagePreviewPage(url: msg.imageUrl!),
                              opaque: false,
                            ),
                          );
                        },
                        child: Hero(
                          tag: msg.imageUrl!,
                          child: Image.network(
                            msg.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 220,
                                height: 160,
                                color: Colors.black12,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  verticalSpace6,
                ],
                if (msg.text.trim().isNotEmpty)
                  ExpandableEmojiText(
                    text: msg.text,
                    style: TextStylesManager.regular16.copyWith(
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                verticalSpace4,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(time),
                      style: TextStylesManager.regular10.copyWith(
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    if (isMe) ...[
                      horizontalSpace6,
                      Icon(
                        msg.seen ? Icons.done_all : Icons.check,
                        size: 14,
                        color: msg.seen
                            ? Colors.lightGreenAccent.shade400
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIosContextMenu(BuildContext context) {
    final alignment = isMe ? Alignment.topRight : Alignment.topLeft;
    showDialog<Object>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (_) {
        return IosStyleContextMenu(
          actions: [
            ContextMenuAndroid(
              label: appTranslation().get("copy"),
              icon: Icons.copy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
              },
            ),
            ContextMenuAndroid(
              label: appTranslation().get("delete"),
              icon: Icons.delete_outline,
              onTap: () {
                // homeCubit.deleteMessage(msg);
              },
            ),
            ContextMenuAndroid(
              label: appTranslation().get("edit"),
              icon: Icons.edit,
              onTap: () {
                // homeCubit.editMsg(msg);
              },
            ),
          ],
          menuAlignment: alignment,
          child: MessageBubble(
            msg: msg,
            isMe: isMe,
          ),
        );
      },
    );
  }
}
