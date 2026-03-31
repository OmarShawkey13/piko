import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_data.dart';

class EmojiTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];
    final characters = text.characters;
    final double fontSize = style?.fontSize ?? 16.0;

    for (var char in characters) {
      final assetPath = EmojiData.getEmojiPath(char);

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
                cacheWidth: (fontSize * 3).toInt(),
              ),
            ),
          ),
        );
      } else {
        children.add(TextSpan(text: char, style: style));
      }
    }

    return TextSpan(style: style, children: children);
  }
}
