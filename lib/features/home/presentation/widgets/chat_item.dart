import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/chat/presentation/screen/chat_screen.dart';

class ChatItem extends StatelessWidget {
  final ChatModel chat;

  const ChatItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<Object>(
            builder: (_) => ChatScreen(
              user: UserModel(
                uid: chat.uid,
                email: "",
                displayName: chat.displayName,
                username: chat.username,
                photoUrl: chat.photoUrl,
                bio: "",
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: homeCubit.isDarkMode
              ? ColorsManager.darkCard
              : ColorsManager.lightCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: chat.photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(chat.photoUrl)
                      : null,
                  child: chat.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(chat.uid)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData || !snap.data!.exists) {
                        return const SizedBox();
                      }

                      final data =
                          snap.data!.data() as Map<String, dynamic>? ?? {};
                      final bool online = data["online"] ?? false;

                      if (!online) return const SizedBox();

                      return Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            horizontalSpace14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.displayName,
                    style: TextStylesManager.bold16.copyWith(
                      color: homeCubit.isDarkMode
                          ? ColorsManager.darkTextPrimary
                          : ColorsManager.lightTextPrimary,
                    ),
                  ),
                  verticalSpace4,
                  StreamBuilder<bool>(
                    stream: homeCubit.getTypingStatus(
                      homeCubit.currentUserModel!.uid,
                      chat.uid,
                    ),
                    builder: (context, snap) {
                      final isTyping = snap.data ?? false;
                      final bool lastMsgIsImage =
                          chat.imageUrl != null && chat.imageUrl!.isNotEmpty;
                      final subtitleStyle = TextStylesManager.regular14
                          .copyWith(
                            color: homeCubit.isDarkMode
                                ? ColorsManager.darkTextSecondary
                                : ColorsManager.lightTextSecondary,
                            height: 1.2,
                          );
                      if (isTyping) {
                        return Text(
                          "Typing...",
                          style: subtitleStyle.copyWith(color: Colors.green),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      if (chat.draft.isNotEmpty) {
                        return EmojiText(
                          text: "Draft: ${chat.draft}",
                          style: subtitleStyle.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      if (lastMsgIsImage) {
                        return Row(
                          children: [
                            Icon(
                              Icons.image,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            horizontalSpace4,
                            Expanded(
                              child: Text(
                                "Photo",
                                style: subtitleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }
                      return EmojiText(
                        text: chat.lastMessage,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),

            /// Timestamp + unreadCount badge
            Column(
              children: [
                Text(
                  _formatTime(chat.timestamp),
                  style: TextStylesManager.regular12.copyWith(
                    color: homeCubit.isDarkMode
                        ? ColorsManager.darkTextSecondary
                        : ColorsManager.lightTextSecondary,
                  ),
                ),
                verticalSpace6,
                if (chat.unreadCount > 0)
                  Badge.count(
                    count: chat.unreadCount,
                    textColor: ColorsManager.darkTextPrimary,
                    backgroundColor: ColorsManager.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final period = dt.hour < 12
        ? appTranslation().get("am")
        : appTranslation().get("pm");
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
