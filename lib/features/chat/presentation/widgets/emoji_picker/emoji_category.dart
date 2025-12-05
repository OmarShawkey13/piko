import 'package:piko/core/theme/emoji_data.dart';

class EmojiCategory {
  final String icon;
  final List<String>? emojis;

  EmojiCategory({
    required this.icon,
    required this.emojis,
  });
}

final List<EmojiCategory> emojiCategories = [
  EmojiCategory(icon: "😊", emojis: EmojiData.data[0]),
  EmojiCategory(icon: "🐵", emojis: EmojiData.data[1]),
  EmojiCategory(icon: "🍎", emojis: EmojiData.data[2]),
  EmojiCategory(icon: "⚽", emojis: EmojiData.data[3]),
  EmojiCategory(icon: "🚗", emojis: EmojiData.data[4]),
  EmojiCategory(icon: "📱", emojis: EmojiData.data[5]),
  EmojiCategory(icon: "❤", emojis: EmojiData.data[6]),
  EmojiCategory(icon: "🇺🇸", emojis: EmojiData.data[7]),
];
