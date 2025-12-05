import 'package:flutter/material.dart';

// ... (Your imports)
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_category.dart';

class EmojiPicker extends StatefulWidget {
  final void Function(String emoji) onEmojiSelected;

  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
  });

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  // 💡 الحل 1: استخدام PageController للتحكم في التمرير
  late PageController _pageController;
  int selectedCategory = 0;

  // تصفية الفئات مرة واحدة
  final List<EmojiCategory> availableCategories = emojiCategories
      .where((c) => c.emojis != null)
      .toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedCategory);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // دالة لمعالجة النقر والتمرير
  void _onCategoryTapped(int index) {
    setState(() {
      selectedCategory = index;
    });
    // التمرير السلس إلى الصفحة الجديدة
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            // Fix: using withOpacity instead of withValues(alpha: 0.03)
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // CATEGORY BAR
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableCategories.length,
              itemBuilder: (_, i) {
                final isActive = i == selectedCategory;
                return GestureDetector(
                  onTap: () => _onCategoryTapped(i),
                  child: Container(
                    width: 46,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: EmojiText(
                        text: availableCategories[i].icon,
                        style: TextStylesManager.regular24.copyWith(
                          fontSize: 27,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 💡 الحل 1: استخدام PageView.builder بدلاً من IndexedStack (Lazy Loading)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: availableCategories.length,
              onPageChanged: (index) {
                setState(() {
                  selectedCategory = index; // تحديث شريط الفئات عند التمرير
                });
              },
              itemBuilder: (context, index) {
                final category = availableCategories[index];
                return _buildEmojiGrid(
                  category.emojis!,
                ); // بناء شبكة واحدة فقط عند العرض
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(List<String> emojis) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => widget.onEmojiSelected(emojis[i]),
          child: Center(
            child: EmojiText(
              text: emojis[i],
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      },
    );
  }
}
