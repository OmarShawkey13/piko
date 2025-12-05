import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/emoji_picker/emoji_picker.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;
  final String myId;
  final String otherId;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isDark,
    required this.myId,
    required this.otherId,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool isEmojiVisible = false;

  void toggleEmojiPicker() {
    setState(() => isEmojiVisible = !isEmojiVisible);
  }

  final FocusNode inputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E1E1E)
                : Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              if (homeCubit.uploadedImageUrl != null) ...[
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        homeCubit.uploadedImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    horizontalSpace12,
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          homeCubit.uploadedImageUrl = null;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
                verticalSpace8,
              ],
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      toggleEmojiPicker();
                      if (isEmojiVisible) {
                        inputFocusNode.unfocus();
                      } else {
                        FocusScope.of(context).requestFocus(inputFocusNode);
                      }
                    },
                    child: Icon(
                      isEmojiVisible
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                  ),
                  horizontalSpace8,
                  GestureDetector(
                    onTap: homeCubit.pickImage,
                    child: Icon(
                      Icons.image,
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        textDirection: homeCubit.isArabicLang
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        controller: widget.controller,
                        focusNode: inputFocusNode,
                        minLines: 1,
                        maxLines: 4,
                        onChanged: (value) {
                          homeCubit.updateDraft(
                            widget.myId,
                            widget.otherId,
                            value,
                          );
                          homeCubit.setTypingStatus(
                            myId: widget.myId,
                            otherId: widget.otherId,
                            isTyping: value.trim().isNotEmpty,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: appTranslation().get("message_hint"),
                          border: InputBorder.none,
                          hintStyle: TextStylesManager.regular14.copyWith(
                            color: widget.isDark
                                ? Colors.white54
                                : Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace8,
                  GestureDetector(
                    onTap: () {
                      homeCubit.setTypingStatus(
                        myId: widget.myId,
                        otherId: widget.otherId,
                        isTyping: false,
                      );
                      widget.onSend();
                    },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: ColorsManager.primary,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: isEmojiVisible ? 320 : 0,
          child: isEmojiVisible
              ? EmojiPicker(
                  onEmojiSelected: (emoji) {
                    widget.controller.text += emoji;
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );
                  },
                )
              : null,
        ),
      ],
    );
  }
}
