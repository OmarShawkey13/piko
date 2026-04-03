import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/chat/presentation/widgets/chat_user_name.dart';
import 'package:piko/features/chat/presentation/widgets/user_online_status.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatStates>(
      buildWhen: (_, state) =>
          state is ChatSelectionModeChangedState ||
          state is ChatSearchToggleState ||
          state is ChatSearchResultsUpdatedState,
      builder: (context, state) {
        final chatCubit = ChatCubit.get(context);

        if (chatCubit.isSearchActive) {
          return PrimaryAppBar(
            centerTitle: false,
            leading: IconButton(
              onPressed: () => chatCubit.toggleSearch(),
              icon: const Icon(Icons.close_rounded),
            ),
            titleWidget: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: appTranslation().get("search"),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: (query) => chatCubit.searchMessages(query),
            ),
            actions: [
              if (chatCubit.searchResultIds.isNotEmpty) ...[
                Center(
                  child: Text(
                    "${chatCubit.currentSearchIndex + 1}/${chatCubit.searchResultIds.length}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: () => chatCubit.previousSearchResult(),
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  onPressed: () => chatCubit.nextSearchResult(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ] else
                horizontalSpace16,
            ],
          );
        }

        if (chatCubit.isSelectionMode) {
          return PrimaryAppBar(
            centerTitle: false,
            leading: IconButton(
              onPressed: () => chatCubit.clearSelection(),
              icon: const Icon(Icons.close_rounded),
            ),
            titleWidget: Text(
              "${chatCubit.selectedMessages.length} ${appTranslation().get("selected")}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () => _showDeleteSelectionDialog(context, chatCubit),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: ColorsManager.error,
                ),
              ),
              horizontalSpace8,
            ],
          );
        }

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
                    backgroundColor: ColorsManager.primary.withValues(
                      alpha: 0.1,
                    ),
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
              onPressed: () => chatCubit.toggleSearch(),
              icon: const Icon(Icons.search_rounded),
              color: ColorsManager.primary,
            ),
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
      },
    );
  }

  void _showDeleteSelectionDialog(BuildContext context, ChatCubit chatCubit) {
    final myUser = authCubit.currentUserModel;
    if (myUser == null) return;

    final allMe = chatCubit.selectedMessages.every(
      (m) => m.senderId == myUser.uid,
    );

    showDialog<Object>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(appTranslation().get("delete_messages")),
        content: Text(
          "${appTranslation().get("delete_confirm_count")} ${chatCubit.selectedMessages.length} ${appTranslation().get("messages")}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appTranslation().get("cancel")),
          ),
          if (allMe)
            TextButton(
              onPressed: () {
                chatCubit.deleteSelectedMessages(
                  myId: myUser.uid,
                  otherId: user.uid,
                  deleteForEveryone: true,
                );
                Navigator.pop(context);
              },
              child: Text(
                appTranslation().get("delete_for_everyone"),
                style: const TextStyle(color: ColorsManager.error),
              ),
            ),
          TextButton(
            onPressed: () {
              chatCubit.deleteSelectedMessages(
                myId: myUser.uid,
                otherId: user.uid,
                deleteForEveryone: false,
              );
              Navigator.pop(context);
            },
            child: Text(appTranslation().get("delete_for_me")),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
