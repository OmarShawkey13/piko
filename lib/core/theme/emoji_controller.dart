import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_data.dart';

class EmojiTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final List<InlineSpan> children = [];
    final double fontSize = style?.fontSize ?? 16.0;

    // استخدام splitMapJoin للبحث عن الإيموجي بكفاءة عالية
    text.splitMapJoin(
      EmojiData.emojiRegex,
      onMatch: (Match match) {
        final emoji = match.group(0)!;
        final assetPath = EmojiData.getEmojiPath(emoji);

        if (assetPath != null) {
          children.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Image.asset(
                  assetPath,
                  width: fontSize * 1.25,
                  height: fontSize * 1.25,
                  // تقليل الـ cacheWidth جداً في الكنترولر لأنه بيتكرر كتير أثناء الكتابة
                  cacheWidth: (fontSize * 2).toInt(),
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
          );
        } else {
          children.add(TextSpan(text: emoji, style: style));
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          children.add(TextSpan(text: nonMatch, style: style));
        }
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
