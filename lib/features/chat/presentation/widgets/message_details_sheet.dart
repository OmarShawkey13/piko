import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class MessageDetailsSheet extends StatelessWidget {
  final MessageModel msg;

  const MessageDetailsSheet({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(msg.timestamp);

    // Manual Time Formatting (HH:mm AM/PM)
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final timeStr = "$hour:$minute $period";

    // Manual Date Formatting (dd MMM yyyy)
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = "${date.day} ${months[date.month - 1]} ${date.year}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          verticalSpace24,
          Text(
            appTranslation().get("message_details"),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace24,
          _buildDetailItem(
            icon: Icons.access_time_rounded,
            label: appTranslation().get("sent"),
            value: timeStr,
            color: ColorsManager.primary,
          ),
          verticalSpace16,
          _buildDetailItem(
            icon: Icons.calendar_today_rounded,
            label: appTranslation().get("date"),
            value: dateStr,
            color: Colors.orange,
          ),
          verticalSpace16,
          _buildDetailItem(
            icon: msg.seen ? Icons.done_all_rounded : Icons.done_rounded,
            label: appTranslation().get("status"),
            value: msg.seen
                ? appTranslation().get("read")
                : appTranslation().get("delivered"),
            color: msg.seen ? ColorsManager.primary : Colors.grey,
          ),
          verticalSpace32,
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          horizontalSpace16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
