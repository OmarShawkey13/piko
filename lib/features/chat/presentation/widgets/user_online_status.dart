import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';

class UserOnlineStatus extends StatelessWidget {
  final String userId;

  const UserOnlineStatus({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox();
        }
        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final bool online = data["online"] ?? false;
        final int lastActive = data["lastActive"] ?? 0;

        return Row(
          children: [
            if (online)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: ColorsManager.success,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              online
                  ? appTranslation().get("active_now")
                  : _formatLastSeen(lastActive),
              style: TextStylesManager.regular12.copyWith(
                color: online
                    ? ColorsManager.success
                    : ColorsManager.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatLastSeen(int ts) {
    if (ts == 0) return appTranslation().get("offline");
    final date = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return appTranslation().get("just_now");
    if (diff.inMinutes < 60) {
      return appTranslation()
          .get("minutes_ago")
          .replaceAll("{n}", diff.inMinutes.toString());
    }

    final isYesterday =
        now.day - date.day == 1 &&
        now.month == date.month &&
        now.year == date.year;

    if (diff.inHours < 24 && !isYesterday) {
      return appTranslation()
          .get("hours_ago")
          .replaceAll("{n}", diff.inHours.toString());
    }

    String dayStr = "";
    if (isYesterday) {
      dayStr = "${appTranslation().get("yesterday")} ";
    } else if (diff.inDays < 7) {
      dayStr = "${date.day}/${date.month} ";
    } else {
      dayStr = "${date.day}/${date.month}/${date.year} ";
    }

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12
        ? appTranslation().get("am")
        : appTranslation().get("pm");
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "$dayStr$hour:$minute $period";
  }
}
