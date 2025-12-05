import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/features/chat/presentation/widgets/chat_appbar.dart';
import 'package:piko/features/chat/presentation/widgets/message_input.dart';
import 'package:piko/features/chat/presentation/widgets/messages_list.dart';
import 'package:piko/features/chat/presentation/widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeCubit.loadChatBackground();
    homeCubit.loadDraft(
      otherId: widget.user.uid,
      messageController: messageController,
    );
  }

  @override
  void dispose() {
    final myId = homeCubit.currentUserModel?.uid;
    if (myId != null) {
      homeCubit.setTypingStatus(
        myId: myId,
        otherId: widget.user.uid,
        isTyping: false,
      );
    }
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeGetUserLoadingState ||
          state is HomeGetUserSuccessState ||
          state is HomeGetUserErrorState,
      builder: (context, state) {
        final myUser = homeCubit.currentUserModel;
        if (myUser == null) {
          return const LoadingIndicator();
        }
        return Scaffold(
          appBar: ChatAppBar(user: widget.user),
          body: Container(
            decoration: homeCubit.chatBackgroundBytes != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(homeCubit.chatBackgroundBytes!),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Column(
              children: [
                Expanded(
                  child: MessagesList(
                    myId: myUser.uid,
                    otherId: widget.user.uid,
                  ),
                ),
                TypingIndicator(
                  myId: myUser.uid,
                  otherId: widget.user.uid,
                ),
                MessageInput(
                  controller: messageController,
                  isDark: homeCubit.isDarkMode,
                  myId: myUser.uid,
                  otherId: widget.user.uid,
                  onSend: () {
                    final text = messageController.text.trim();
                    final imageUrl = homeCubit.uploadedImageUrl;
                    if (text.isEmpty &&
                        (imageUrl == null || imageUrl.isEmpty)) {
                      return;
                    }
                    homeCubit.sendMessage(
                      myId: myUser.uid,
                      otherId: widget.user.uid,
                      text: text,
                      myUser: myUser,
                      otherUser: widget.user,
                      imageUrl: imageUrl,
                    );
                    messageController.clear();
                    homeCubit.uploadedImageUrl = null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
