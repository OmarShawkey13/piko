import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : null,
            child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          horizontalSpace10,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Display name
              Text(
                user.displayName.isNotEmpty ? user.displayName : user.username,
                style: TextStylesManager.regular16.copyWith(
                  color: homeCubit.isDarkMode
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                ),
              ),

              /// ONLINE / LAST SEEN / TYPING
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData || !snap.data!.exists) {
                    return Text(
                      "Loading...",
                      style: TextStylesManager.regular12.copyWith(
                        color: homeCubit.isDarkMode
                            ? ColorsManager.darkTextSecondary
                            : ColorsManager.lightTextSecondary,
                      ),
                    );
                  }
                  final data = snap.data!.data() as Map<String, dynamic>? ?? {};
                  final bool online = data["online"] ?? false;
                  final int lastActive = data["lastActive"] ?? 0;
                  return Text(
                    online ? "Online" : _formatLastSeen(lastActive),
                    style: TextStylesManager.regular12.copyWith(
                      color: online ? Colors.green : Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.wallpaper),
          onPressed: () async {
            await homeCubit.pickChatBackground();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// LAST SEEN formatter
  String _formatLastSeen(int ts) {
    if (ts == 0) return "Offline";
    final date = DateTime.fromMillisecondsSinceEpoch(ts);
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12
        ? appTranslation().get("am")
        : appTranslation().get("pm");
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $period";
  }
}
