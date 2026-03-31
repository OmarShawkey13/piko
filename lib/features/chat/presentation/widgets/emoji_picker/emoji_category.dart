import 'package:piko/core/theme/emoji_data.dart';

class EmojiCategory {
  final String icon;
  final List<String>? emojis;
  final bool isRecent;

  EmojiCategory({
    required this.icon,
    this.emojis,
    this.isRecent = false,
  });
}

final List<EmojiCategory> emojiCategories = [
  EmojiCategory(icon: "🕒", emojis: [], isRecent: true),
  EmojiCategory(icon: "😊", emojis: EmojiData.data[0]),
  EmojiCategory(icon: "🐵", emojis: EmojiData.data[1]),
  EmojiCategory(icon: "🍎", emojis: EmojiData.data[2]),
  EmojiCategory(icon: "⚽", emojis: EmojiData.data[3]),
  EmojiCategory(icon: "🚗", emojis: EmojiData.data[4]),
  EmojiCategory(icon: "📱", emojis: EmojiData.data[5]),
  EmojiCategory(icon: "❤", emojis: EmojiData.data[6]),
  EmojiCategory(icon: "🇺🇸", emojis: EmojiData.data[7]),
];
