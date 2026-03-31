import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/features/chat/presentation/screen/chat_screen.dart';
import 'package:piko/features/home/presentation/widgets/chat_preview_dialog.dart';
import 'package:piko/features/home/presentation/widgets/conversation_avatar.dart';
import 'package:piko/features/home/presentation/widgets/conversation_info.dart';
import 'package:piko/features/home/presentation/widgets/conversation_trailing.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class ConversationItem extends StatelessWidget {
  final ChatModel chat;

  const ConversationItem({super.key, required this.chat});

  void _showChatPreview(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ChatPreview",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return ChatPreviewDialog(chat: chat);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
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
              color: themeCubit.isDarkMode
                  ? ColorsManager.darkCard
                  : ColorsManager.lightCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                ConversationAvatar(
                  chat: chat,
                  onLongPressStart: () => _showChatPreview(context),
                  onLongPressEnd: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                horizontalSpace14,
                ConversationInfo(chat: chat),
                ConversationTrailing(chat: chat),
              ],
            ),
          ),
        );
      },
    );
  }
}
