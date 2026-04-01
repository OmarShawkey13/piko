import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/chat/presentation/widgets/chat_user_name.dart';
import 'package:piko/features/chat/presentation/widgets/user_online_status.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PrimaryAppBar(
      centerTitle: false,
      leading: IconButton(
        onPressed: () => context.pop,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Hero(
              tag: user.uid,
              child: PrimaryCircleAvatar(
                imageUrl: user.photoUrl,
                radius: 20,
                useCachedImage: true,
                backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
                fallbackIcon: Icons.person,
              ),
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChatUserName(user: user),
                  UserOnlineStatus(userId: user.uid),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ChatCubit.get(context).pickChatBackground(),
          icon: const Icon(
            Icons.palette_outlined,
            color: ColorsManager.primary,
          ),
          tooltip: appTranslation().get("chat_background"),
        ),
        horizontalSpace8,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
