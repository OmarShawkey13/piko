import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final String myId;
  final String otherId;

  const TypingIndicator({
    super.key,
    required this.myId,
    required this.otherId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(otherId)
          .collection("chats")
          .doc(myId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        final data = snap.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox();
        final isTyping = data["isTyping"] ?? false;
        if (!isTyping) return const SizedBox();
        return const Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _TypingBubble(),
          ),
        );
      },
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFFE8EAED);
    const Color dotColor = Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: controller,
            builder: (_, child) {
              final double delay = i * 0.2;
              final double bounceValue = Tween<double>(begin: 0.0, end: 1.0)
                  .evaluate(
                    CurvedAnimation(
                      parent: controller,
                      curve: Interval(
                        delay,
                        delay + 0.6,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  );
              final double yOffset = (1.0 - bounceValue) * -4.0;
              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
