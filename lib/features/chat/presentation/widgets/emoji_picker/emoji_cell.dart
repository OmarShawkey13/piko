import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_image.dart';

class EmojiCell extends StatelessWidget {
  final String emoji;
  final List<String>? variants;
  final void Function(String) onSelected;

  const EmojiCell({
    super.key,
    required this.emoji,
    this.variants,
    required this.onSelected,
  });

  void _showSkinToneMenu(BuildContext context) {
    if (variants == null || variants!.isEmpty) return;

    HapticFeedback.lightImpact();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size cellSize = box.size;

    final List<String> allOptions = [emoji, ...variants!];
    const double itemWidth = 42.0;
    const double horizontalPadding = 20.0;
    final double menuWidth =
        (allOptions.length * itemWidth) + horizontalPadding;
    const double menuHeight = 58.0;

    double left = position.dx + (cellSize.width / 2) - (menuWidth / 2);
    final screenWidth = MediaQuery.of(context).size.width;
    left = left.clamp(8.0, screenWidth - menuWidth - 8.0);

    double top = position.dy - menuHeight - 8;
    if (top < 100) {
      top = position.dy + cellSize.height + 8;
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => overlayEntry.remove(),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 12,
              shadowColor: Colors.black45,
              color: themeCubit.isDarkMode
                  ? const Color(0xFF2D3748)
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: allOptions.map((e) {
                    return GestureDetector(
                      onTap: () {
                        onSelected(e);
                        overlayEntry.remove();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: EmojiImage(emoji: e, size: 32),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(emoji),
      onLongPress: () => _showSkinToneMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Center(child: EmojiImage(emoji: emoji, size: 32)),
          if (variants != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.arrow_drop_down_rounded,
                size: 14,
                color: themeCubit.isDarkMode ? Colors.white38 : Colors.black26,
              ),
            ),
        ],
      ),
    );
  }
}
