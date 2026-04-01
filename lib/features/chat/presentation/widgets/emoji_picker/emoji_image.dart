import 'package:flutter/material.dart';
import 'package:piko/core/theme/emoji_data.dart';

class EmojiImage extends StatelessWidget {
  final String emoji;
  final double size;

  const EmojiImage({super.key, required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    final asset = EmojiData.getEmojiPath(emoji);
    if (asset == null) return Text(emoji, style: TextStyle(fontSize: size));

    return Image.asset(
      asset,
      width: size,
      height: size,
      cacheWidth: 66,
      cacheHeight: 66,
      filterQuality: FilterQuality.medium,
    );
  }
}
