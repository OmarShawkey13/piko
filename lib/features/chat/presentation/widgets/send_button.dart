import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';

class SendButton extends StatelessWidget {
  final bool isDark;
  final bool isTextEmpty;
  final VoidCallback onTap;

  const SendButton({
    super.key,
    required this.isDark,
    required this.isTextEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isTextEmpty
              ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
              : ColorsManager.primary,
          shape: BoxShape.circle,
          boxShadow: isTextEmpty
              ? []
              : [
                  BoxShadow(
                    color: ColorsManager.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          Icons.send_rounded,
          color: isTextEmpty ? Colors.grey : ColorsManager.white,
          size: 24,
        ),
      ),
    );
  }
}
