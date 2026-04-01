import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
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
    HapticFeedback.mediumImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ChatPreview",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return ChatPreviewDialog(chat: chat);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ).value,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeIn,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) => state is HomeChangeScaleState,
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        final isItemActive = cubit.activeId == chat.uid;

        return GestureDetector(
          onTapDown: (_) => cubit.changeScale(chat.uid, 0.95),
          onTapUp: (_) => cubit.changeScale(chat.uid, 1.0),
          onTapCancel: () => cubit.changeScale(chat.uid, 1.0),
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
          child: AnimatedScale(
            scale: isItemActive ? cubit.scale : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: themeCubit.isDarkMode
                    ? ColorsManager.darkCard
                    : ColorsManager.lightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),
                  horizontalSpace14,
                  ConversationInfo(chat: chat),
                  ConversationTrailing(chat: chat),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
