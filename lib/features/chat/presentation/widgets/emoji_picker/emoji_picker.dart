import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_category_bar.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_cell.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_category.dart';

class EmojiPicker extends StatefulWidget {
  final void Function(String emoji) onEmojiSelected;

  const EmojiPicker({super.key, required this.onEmojiSelected});

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  late PageController _pageController;
  int selectedCategory = 0;

  final List<List<String>> processedCategories = [];
  final Map<String, List<String>> emojiVariants = {};
  List<String> recentEmojis = [];

  @override
  void initState() {
    super.initState();
    _loadRecentEmojis();
    _pageController = PageController(initialPage: selectedCategory);
    _initializeEmojis();
  }

  void _loadRecentEmojis() {
    final String? encoded = CacheHelper.getData(key: "recent_emojis");
    if (encoded != null) {
      try {
        recentEmojis = List<String>.from(jsonDecode(encoded));
      } catch (e) {
        recentEmojis = [];
      }
    }
  }

  void _saveRecentEmoji(String emoji) {
    recentEmojis.remove(emoji);
    recentEmojis.insert(0, emoji);
    if (recentEmojis.length > 40) {
      recentEmojis = recentEmojis.sublist(0, 40);
    }
    CacheHelper.saveData(key: "recent_emojis", value: jsonEncode(recentEmojis));

    if (emojiCategories.isNotEmpty && emojiCategories[0].isRecent) {
      setState(() {
        processedCategories[0] = List.from(recentEmojis);
      });
    }
  }

  void _initializeEmojis() {
    const skinTones = ['🏻', '🏼', '🏽', '🏾', '🏿'];
    processedCategories.clear();
    emojiVariants.clear();

    for (var category in emojiCategories) {
      if (category.isRecent) {
        processedCategories.add(List.from(recentEmojis));
        continue;
      }

      final List<String> allEmojisInCat = category.emojis ?? [];
      final List<String> baseEmojis = [];

      for (int i = 0; i < allEmojisInCat.length; i++) {
        final String current = allEmojisInCat[i];
        final bool isVariant = skinTones.any((tone) => current.contains(tone));
        if (isVariant) continue;

        baseEmojis.add(current);

        final List<String> variants = [];
        int j = i + 1;
        while (j < allEmojisInCat.length) {
          final String next = allEmojisInCat[j];
          final bool nextIsVariant = skinTones.any(
            (tone) => next.contains(tone),
          );
          if (nextIsVariant && next.contains(current)) {
            variants.add(next);
            j++;
          } else {
            break;
          }
        }

        if (variants.isNotEmpty) {
          emojiVariants[current] = variants;
          i = j - 1;
        }
      }
      processedCategories.add(baseEmojis);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = themeCubit.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : ColorsManager.lightBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? ColorsManager.borderColor
                : ColorsManager.bubbleOtherLight,
          ),
        ),
      ),
      child: Column(
        children: [
          EmojiCategoryBar(
            selectedCategory: selectedCategory,
            onCategorySelected: (index) {
              setState(() => selectedCategory = index);
              _pageController.jumpToPage(index);
            },
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: processedCategories.length,
              onPageChanged: (index) =>
                  setState(() => selectedCategory = index),
              itemBuilder: (context, index) {
                if (index == 0 &&
                    emojiCategories[0].isRecent &&
                    processedCategories[0].isEmpty) {
                  return Center(
                    child: Text(
                      appTranslation().get("no_recent_emojis"),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  );
                }
                return RepaintBoundary(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                    itemCount: processedCategories[index].length,
                    itemBuilder: (context, i) {
                      final emoji = processedCategories[index][i];
                      return EmojiCell(
                        emoji: emoji,
                        variants: emojiVariants[emoji],
                        onSelected: (e) {
                          _saveRecentEmoji(e);
                          widget.onEmojiSelected(e);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
