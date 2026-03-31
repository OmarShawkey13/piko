import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/chat/presentation/widgets/user_online_status.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => context.pop,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            _buildUserAvatar(),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUserName(),
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

  Widget _buildUserAvatar() {
    return Hero(
      tag: user.uid,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
        backgroundImage: user.photoUrl.isNotEmpty
            ? CachedNetworkImageProvider(user.photoUrl)
            : null,
        child: user.photoUrl.isEmpty
            ? const Icon(Icons.person, color: ColorsManager.primary)
            : null,
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      user.displayName.isNotEmpty ? user.displayName : user.username,
      style: TextStylesManager.bold16.copyWith(
        color: ColorsManager.textPrimary,
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
