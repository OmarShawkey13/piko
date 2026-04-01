import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/utils/constants/constants.dart';

class ExpandableEmojiText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int trimLines;

  const ExpandableEmojiText({
    super.key,
    required this.text,
    this.style,
    this.trimLines = 35,
  });

  @override
  State<ExpandableEmojiText> createState() => _ExpandableEmojiTextState();
}

class _ExpandableEmojiTextState extends State<ExpandableEmojiText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    final style = widget.style ?? DefaultTextStyle.of(context).style;

    // 🚀 حساب العرض المتاح للرسالة بناءً على تصميم الـ MessageBubble
    // 0.78 هو النسبة المحددة في MessageBubble، والـ 40 هي الهوامش والـ Padding التقريبي
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxBubbleWidth = screenWidth * 0.78 - 40;

    // حساب الـ Overflow بدون استخدام LayoutBuilder لتجنب مشاكل الـ Sliver Layout
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.trimLines,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxBubbleWidth > 0 ? maxBubbleWidth : 0);

    final bool isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // استخدام AnimatedSize بحذر مع التأكد من وجود قيود واضحة
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          child: _isExpanded
              ? EmojiText(
                  text: widget.text,
                  style: widget.style,
                )
              : EmojiText(
                  text: widget.text,
                  style: widget.style,
                  maxLines: widget.trimLines,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        if (isOverflowing)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Text(
                _isExpanded
                    ? appTranslation().get("read_less")
                    : appTranslation().get("read_more"),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
