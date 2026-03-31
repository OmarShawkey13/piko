import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/chat/presentation/widgets/attachment_menu.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_picker.dart';
import 'package:piko/features/chat/presentation/widgets/reply_preview.dart';
import 'package:piko/features/chat/presentation/widgets/send_button.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;
  final String myId;
  final String otherId;
  final UserModel otherUser;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isDark,
    required this.myId,
    required this.otherId,
    required this.otherUser,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool isEmojiVisible = false;
  final FocusNode inputFocusNode = FocusNode();
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    inputFocusNode.addListener(() {
      if (inputFocusNode.hasFocus) {
        setState(() => isEmojiVisible = false);
      }
    });
  }

  void _onTextChanged() {
    if (widget.controller.text.trim().isEmpty != isTextEmpty) {
      setState(() {
        isTextEmpty = widget.controller.text.trim().isEmpty;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    inputFocusNode.dispose();
    super.dispose();
  }

  void toggleEmojiPicker() {
    if (isEmojiVisible) {
      inputFocusNode.requestFocus();
    } else {
      inputFocusNode.unfocus();
      setState(() => isEmojiVisible = true);
    }
  }

  void _showAttachmentMenu(BuildContext context) {
    final chatCubit = ChatCubit.get(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => AttachmentMenu(
        isDark: widget.isDark,
        onCameraTap: () async {
          context.pop;
          final files = await chatCubit.pickMediaFiles(
            source: ImageSource.camera,
          );
          if (files.isNotEmpty) {
            await chatCubit.uploadAndSend(
              files: files,
              myId: widget.myId,
              otherId: widget.otherId,
              myUser: authCubit.currentUserModel!,
              otherUser: widget.otherUser,
            );
          }
        },
        onVideoTap: () async {
          context.pop;
          final files = await chatCubit.pickMediaFiles(
            source: ImageSource.camera,
            isVideo: true,
          );
          if (files.isNotEmpty) {
            await chatCubit.uploadAndSend(
              files: files,
              myId: widget.myId,
              otherId: widget.otherId,
              myUser: authCubit.currentUserModel!,
              otherUser: widget.otherUser,
            );
          }
        },
        onGalleryTap: () async {
          context.pop;
          final files = await chatCubit.pickMediaFiles(
            source: ImageSource.gallery,
          );
          if (files.isNotEmpty) {
            await chatCubit.uploadAndSend(
              files: files,
              myId: widget.myId,
              otherId: widget.otherId,
              myUser: authCubit.currentUserModel!,
              otherUser: widget.otherUser,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final chatCubit = ChatCubit.get(context);
    return BlocBuilder<ChatCubit, ChatStates>(
      buildWhen: (_, state) => state is ChatReplyingMessageChangedState,
      builder: (context, state) {
        final replyingMessage = chatCubit.replyingMessage;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.darkCard
                            : ColorsManager.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (replyingMessage != null)
                            ReplyPreview(
                              replyingMessage: replyingMessage,
                              isDark: isDark,
                              myId: widget.myId,
                              otherDisplayName: widget.otherUser.displayName,
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: toggleEmojiPicker,
                                icon: Icon(
                                  isEmojiVisible
                                      ? Icons.keyboard_rounded
                                      : Icons.emoji_emotions_outlined,
                                  color: ColorsManager.primary,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: inputFocusNode,
                                  minLines: 1,
                                  maxLines: 5,
                                  style: TextStylesManager.regular14.copyWith(
                                    color: isDark
                                        ? ColorsManager.darkTextPrimary
                                        : ColorsManager.lightTextPrimary,
                                  ),
                                  onChanged: (value) {
                                    chatCubit.updateDraft(
                                      widget.myId,
                                      widget.otherId,
                                      value,
                                    );
                                    chatCubit.setTypingStatus(
                                      myId: widget.myId,
                                      otherId: widget.otherId,
                                      isTyping: value.trim().isNotEmpty,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: appTranslation().get(
                                      "message_hint",
                                    ),
                                    border: InputBorder.none,
                                    hintStyle: TextStylesManager.regular14
                                        .copyWith(
                                          color: isDark
                                              ? ColorsManager.darkTextSecondary
                                              : ColorsManager
                                                    .lightTextSecondary,
                                        ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showAttachmentMenu(context),
                                icon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: isDark
                                      ? ColorsManager.darkTextSecondary
                                      : ColorsManager.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  horizontalSpace10,
                  SendButton(
                    isDark: isDark,
                    isTextEmpty: isTextEmpty,
                    onTap: () {
                      if (!isTextEmpty) {
                        chatCubit.setTypingStatus(
                          myId: widget.myId,
                          otherId: widget.otherId,
                          isTyping: false,
                        );
                        widget.onSend();
                      }
                    },
                  ),
                ],
              ),
            ),
            if (isEmojiVisible)
              SizedBox(
                height: 320,
                child: EmojiPicker(
                  onEmojiSelected: (emoji) {
                    widget.controller.text += emoji;
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
