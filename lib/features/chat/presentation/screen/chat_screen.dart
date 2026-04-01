import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/di/injections.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/emoji_controller.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/chat_appbar.dart';
import 'package:piko/features/chat/presentation/widgets/message_input.dart';
import 'package:piko/features/chat/presentation/widgets/messages_list.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = EmojiTextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatCubit>()
        ..loadChatBackground()
        ..loadDraft(
          otherId: widget.user.uid,
          messageController: messageController,
        ),
      child: BlocBuilder<AuthCubit, AuthStates>(
        buildWhen: (_, state) =>
            state is AuthGetUserLoadingState ||
            state is AuthGetUserSuccessState ||
            state is AuthGetUserErrorState,
        builder: (context, state) {
          final myUser = authCubit.currentUserModel;
          return ConditionalBuilder(
            loadingState: myUser == null,
            successBuilder: (context) {
              final chatCubit = ChatCubit.get(context);
              return Scaffold(
                appBar: ChatAppBar(user: widget.user),
                body: BlocBuilder<ChatCubit, ChatStates>(
                  buildWhen: (_, state) => state is ChatBackgroundChangedState,
                  builder: (context, state) {
                    return Container(
                      decoration: chatCubit.chatBackgroundBytes != null
                          ? BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(
                                  chatCubit.chatBackgroundBytes!,
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      child: Column(
                        children: [
                          Expanded(
                            child: RepaintBoundary(
                              child: MessagesList(
                                myId: myUser!.uid,
                                otherId: widget.user.uid,
                              ),
                            ),
                          ),
                          MessageInput(
                            controller: messageController,
                            isDark: themeCubit.isDarkMode,
                            myId: myUser.uid,
                            otherId: widget.user.uid,
                            otherUser: widget.user,
                            onSend: () {
                              final text = messageController.text.trim();
                              if (text.isEmpty) return;
                              chatCubit.sendMessage(
                                myId: myUser.uid,
                                otherId: widget.user.uid,
                                text: text,
                                myUser: myUser,
                                otherUser: widget.user,
                              );
                              messageController.clear();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
