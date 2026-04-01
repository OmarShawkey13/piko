import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/expandable_emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';

class MessageBubbleText extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubbleText({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: ExpandableEmojiText(
        text: text,
        style: TextStylesManager.regular16.copyWith(
          color: isMe ? ColorsManager.white : ColorsManager.bubbleOtherText,
          height: 1.35,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
