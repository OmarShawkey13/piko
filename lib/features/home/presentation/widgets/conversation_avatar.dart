import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';

class ConversationAvatar extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const ConversationAvatar({
    super.key,
    required this.chat,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: chat.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(chat.photoUrl)
                : null,
            child: chat.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          OnlineIndicator(userId: chat.uid),
        ],
      ),
    );
  }
}

class OnlineIndicator extends StatelessWidget {
  final String userId;

  const OnlineIndicator({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 2,
      right: 2,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const SizedBox();
          }

          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
          final bool online = data["online"] ?? false;

          if (!online) return const SizedBox();

          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: ColorsManager.success,
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorsManager.white,
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
