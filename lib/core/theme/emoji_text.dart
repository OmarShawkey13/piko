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
    final List<InlineSpan> spans = [];

    // استخدام splitMapJoin مع RegExp أسرع بكثير من الدوران على كل حرف
    text.splitMapJoin(
      EmojiData.emojiRegex,
      onMatch: (Match match) {
        final emoji = match.group(0)!;
        final assetPath = EmojiData.getEmojiPath(emoji);

        if (assetPath != null) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Image.asset(
                  assetPath,
                  width: fontSize * 1.3,
                  height: fontSize * 1.3,
                  // تحديد cacheWidth يقلل جداً من استهلاك الذاكرة
                  cacheWidth: (fontSize * 2.5).toInt(),
                  filterQuality: FilterQuality.low, // أخف في الرندرة
                  errorBuilder: (context, error, stackTrace) =>
                      Text(emoji, style: effectiveStyle),
                ),
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: emoji, style: effectiveStyle));
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(TextSpan(text: nonMatch, style: effectiveStyle));
        }
        return '';
      },
    );

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
