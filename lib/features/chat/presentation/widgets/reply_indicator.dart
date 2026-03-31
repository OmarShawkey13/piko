import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';

class ReplyIndicator extends StatelessWidget {
  final double dragOffset;
  final bool isReplyTriggered;

  const ReplyIndicator({
    super.key,
    required this.dragOffset,
    required this.isReplyTriggered,
  });

  @override
  Widget build(BuildContext context) {
    if (dragOffset <= 0) return const SizedBox.shrink();
    return Positioned(
      left: dragOffset / 3,
      child: AnimatedScale(
        scale: isReplyTriggered ? 1.2 : 0.8,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ColorsManager.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.reply_rounded,
            color: ColorsManager.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
