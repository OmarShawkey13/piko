import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_data.dart';

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final bool softWrap;

  const EmojiText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = effectiveStyle.fontSize ?? 14.0;
    final spans = <InlineSpan>[];

    final characters = text.characters;
    final StringBuffer textBuffer = StringBuffer();

    for (final char in characters) {
      final assetPath = EmojiData.getEmojiPath(char);

      if (assetPath != null) {
        if (textBuffer.isNotEmpty) {
          spans.add(
            TextSpan(text: textBuffer.toString(), style: effectiveStyle),
          );
          textBuffer.clear();
        }

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Image.asset(
                assetPath,
                width: fontSize * 1.3,
                height: fontSize * 1.3,
                isAntiAlias: true,
                filterQuality: FilterQuality.medium,
                // 🚀 محاولة إزالة الحواف السوداء عن طريق تحسين الرندرة
                cacheWidth: (fontSize * 3).toInt(),
                errorBuilder: (context, error, stackTrace) =>
                    Text(char, style: effectiveStyle),
              ),
            ),
          ),
        );
      } else {
        textBuffer.write(char);
      }
    }

    if (textBuffer.isNotEmpty) {
      spans.add(TextSpan(text: textBuffer.toString(), style: effectiveStyle));
    }

    final textScaler = textScaleFactor != null
        ? TextScaler.linear(textScaleFactor!)
        : MediaQuery.of(context).textScaler;

    return RichText(
      text: TextSpan(style: effectiveStyle, children: spans),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: textScaler,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      softWrap: softWrap,
    );
  }
}
