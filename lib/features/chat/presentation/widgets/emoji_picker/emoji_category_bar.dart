import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_image.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_category.dart';

class EmojiCategoryBar extends StatelessWidget {
  final int selectedCategory;
  final void Function(int) onCategorySelected;

  const EmojiCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: emojiCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, i) {
          final isActive = i == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? ColorsManager.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.4,
                  child: EmojiImage(
                    emoji: emojiCategories[i].icon,
                    size: 22,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
