import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_data.dart';

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final double? textScaleFactor; // يُستخدم الآن لإنشاء TextScaler
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
    // تحديد نمط الخط الأساسي وتطبيق التعديلات الافتراضية
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);

    // حساب حجم الخط الفعلي لاستخدامه كمقياس لصور الرموز التعبيرية
    final fontSize = effectiveStyle.fontSize ?? 14.0;

    final spans = <InlineSpan>[];

    // ✅ استخدام characters package لتقسيم السلسلة حسب الرموز التعبيرية (Graphemes)
    for (final char in text.characters) {
      if (EmojiData.emojis.containsKey(char)) {
        // 🛑 تنبيه الأداء: WidgetSpan مع Image.asset هو المعرقل الرئيسي.
        // تم تبسيط حساب الحجم ليكون مساوياً لحجم الخط
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            baseline: TextBaseline.alphabetic, // يساعد في محاذاة أفضل
            child: Image.asset(
              EmojiData.emojis[char]!,
              width: fontSize,
              height: fontSize,
              // يمكن إضافة key هنا لتحسين أداء ListView
              key: ValueKey(char),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: char,
            style: effectiveStyle,
          ),
        );
      }
    }

    // إنشاء TextScaler بناءً على textScaleFactor الممرر أو استخدام مقياس الـ Media
    final textScaler = textScaleFactor != null
        ? TextScaler.linear(textScaleFactor!)
        : MediaQuery.of(context).textScaler;

    return RichText(
      text: TextSpan(style: effectiveStyle, children: spans),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      // ✅ استخدام textScaler الجديد
      textScaler: textScaler,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      softWrap: softWrap,
    );
  }
}
