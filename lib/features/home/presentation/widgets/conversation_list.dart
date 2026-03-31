import 'package:flutter/material.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/features/home/presentation/widgets/conversation_item.dart';

class ConversationList extends StatelessWidget {
  final List<ChatModel> chats;

  const ConversationList({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: chats.length,
      separatorBuilder: (_, _) => verticalSpace12,
      itemBuilder: (_, i) => ConversationItem(chat: chats[i]),
    );
  }
}
