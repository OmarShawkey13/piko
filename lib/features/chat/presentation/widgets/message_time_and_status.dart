import 'package:flutter/material.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/constants/constants.dart';

class MessageTimeAndStatus extends StatelessWidget {
  final int timestamp;
  final bool isMe;
  final bool seen;
  final bool isUploading;
  final bool onImage;

  const MessageTimeAndStatus({
    super.key,
    required this.timestamp,
    required this.isMe,
    required this.seen,
    required this.isUploading,
    this.onImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final Color textColor = onImage
        ? Colors.white
        : (isMe
              ? ColorsManager.bubbleMeText.withValues(alpha: 0.6)
              : ColorsManager.textSecondary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!onImage) horizontalSpace12,
        Text(
          _formatTime(time),
          style: TextStylesManager.regular10.copyWith(
            color: textColor,
            shadows: onImage
                ? [const Shadow(blurRadius: 3.0, color: Colors.black54)]
                : null,
          ),
        ),
        if (isMe) ...[
          horizontalSpace4,
          if (isUploading)
            const Icon(Icons.access_time, size: 14, color: Colors.white70)
          else
            Icon(
              seen ? Icons.done_all : Icons.check,
              size: 14,
              color: seen
                  ? ColorsManager.accent
                  : (onImage ? Colors.white : textColor),
              shadows: onImage
                  ? [const Shadow(blurRadius: 3.0, color: Colors.black54)]
                  : null,
            ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final period = dt.hour < 12
        ? appTranslation().get('am')
        : appTranslation().get('pm');
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}
