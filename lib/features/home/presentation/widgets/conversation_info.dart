import 'package:flutter/material.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';

class ConversationInfo extends StatelessWidget {
  final ChatModel chat;

  const ConversationInfo({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmojiText(
            text: chat.displayName,
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.textPrimary,
            ),
          ),
          verticalSpace4,
          LastMessage(chat: chat),
        ],
      ),
    );
  }
}

class LastMessage extends StatelessWidget {
  final ChatModel chat;

  const LastMessage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: homeCubit.getTypingStatus(
        authCubit.currentUserModel!.uid,
        chat.uid,
      ),
      builder: (context, snap) {
        final isTyping = snap.data ?? false;
        final bool lastMsgIsImage =
            chat.imageUrl != null && chat.imageUrl!.isNotEmpty;
        final subtitleStyle = TextStylesManager.regular14.copyWith(
          color: ColorsManager.textSecondary,
          height: 1.2,
        );
        if (isTyping) {
          return Text(
            "Typing...",
            style: subtitleStyle.copyWith(
              color: ColorsManager.success,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        if (chat.draft.isNotEmpty) {
          return EmojiText(
            text: "Draft: ${chat.draft}",
            style: subtitleStyle.copyWith(
              color: ColorsManager.darkTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        if (lastMsgIsImage) {
          return Row(
            children: [
              const Icon(
                Icons.image,
                size: 16,
                color: ColorsManager.darkTextSecondary,
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
    );
  }
}
