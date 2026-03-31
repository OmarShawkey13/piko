import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/di/injections.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/messages_list.dart';

class ChatPreviewDialog extends StatelessWidget {
  final ChatModel chat;

  const ChatPreviewDialog({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BlocProvider(
        create: (context) => sl<ChatCubit>(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: themeCubit.isDarkMode
                          ? ColorsManager.darkCard
                          : ColorsManager.lightCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PreviewHeader(chat: chat),
                        Flexible(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                            child: MessagesList(
                              myId: authCubit.currentUserModel!.uid,
                              otherId: chat.uid,
                              isPreview: true,
                            ),
                          ),
                        ),
                      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorsManager.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: chat.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(chat.photoUrl)
                : null,
            child: chat.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 22)
                : null,
          ),
          horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmojiText(
                  text: chat.displayName,
                  style: TextStylesManager.bold16,
                ),
                Text(
                  "Chat Preview",
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReleaseToCloseLabel extends StatelessWidget {
  const ReleaseToCloseLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "Release to close",
        style: TextStylesManager.medium14.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
