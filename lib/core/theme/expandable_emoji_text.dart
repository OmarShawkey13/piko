import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_text.dart';

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
  bool isExpanded = false;
  bool isOverflowing = false;

  final keyText = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = keyText.currentContext?.findRenderObject();
      if (renderBox is RenderBox) {
        final maxLinesHeight =
            widget.trimLines * (widget.style?.fontSize ?? 15) * 1.3;
        setState(() {
          isOverflowing = renderBox.size.height > maxLinesHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: EmojiText(
            key: keyText,
            text: widget.text,
            style: widget.style,
            maxLines: widget.trimLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: EmojiText(
            text: widget.text,
            style: widget.style,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 150),
        ),
        if (isOverflowing)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? "Read less" : "Read more",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
