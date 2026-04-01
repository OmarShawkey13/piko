import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/di/injections.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/messages_list.dart';

class ChatPreviewDialog extends StatelessWidget {
  final ChatModel chat;

  const ChatPreviewDialog({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: BlocProvider(
        create: (context) => sl<ChatCubit>()..loadChatBackground(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // النافذة الرئيسية بتصميم عصري
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: themeCubit.isDarkMode
                          ? ColorsManager.darkCard
                          : ColorsManager.lightCard,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: -10,
                          offset: const Offset(0, 20),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: themeCubit.isDarkMode ? 0.05 : 0.5,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PreviewHeader(chat: chat),
                          Flexible(
                            child: BlocBuilder<ChatCubit, ChatStates>(
                              buildWhen: (_, state) =>
                                  state is ChatBackgroundChangedState,
                              builder: (context, state) {
                                final chatCubit = ChatCubit.get(context);
                                return Container(
                                  decoration:
                                      chatCubit.chatBackgroundBytes != null
                                      ? BoxDecoration(
                                          image: DecorationImage(
                                            image: MemoryImage(
                                              chatCubit.chatBackgroundBytes!,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : BoxDecoration(
                                          color: themeCubit.isDarkMode
                                              ? ColorsManager.darkBackground
                                              : ColorsManager.lightBackground,
                                        ),
                                  child: MessagesList(
                                    myId: authCubit.currentUserModel!.uid,
                                    otherId: chat.uid,
                                    isPreview: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace20,
                  const ReleaseToCloseLabel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewHeader extends StatelessWidget {
  final ChatModel chat;

  const PreviewHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color:
                (themeCubit.isDarkMode
                        ? ColorsManager.darkCard
                        : ColorsManager.lightCard)
                    .withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: ColorsManager.borderColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorsManager.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: PrimaryCircleAvatar(
                  imageUrl: chat.photoUrl,
                  radius: 24,
                  useCachedImage: true,
                  backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
                  fallbackIcon: Icons.person,
                  iconSize: 28,
                ),
              ),
              horizontalSpace16,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmojiText(
                    text: chat.displayName,
                    style: TextStylesManager.bold18.copyWith(
                      color: ColorsManager.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Chat Preview",
                    style: TextStylesManager.medium12.copyWith(
                      color: ColorsManager.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReleaseToCloseLabel extends StatelessWidget {
  const ReleaseToCloseLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 32,
        ),
        verticalSpace8,
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                "Release to close",
                style: TextStylesManager.bold14.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
