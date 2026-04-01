import 'package:flutter/material.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/features/chat/presentation/widgets/typing_bubble.dart';

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
    return StreamBuilder<bool>(
      stream: ChatCubit.get(context).getTypingStatus(myId, otherId),
      builder: (context, snap) {
        return ConditionalBuilder(
          loadingState: false, // لا نريد Loader هنا لأنها حالة ثانوية
          successBuilder: (context) {
            final isTyping = snap.data ?? false;
            if (!isTyping) return const SizedBox.shrink();
            return const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 60,
                  top: 4,
                  bottom: 8,
                ),
                child: TypingBubble(),
              ),
            );
          },
        );
      },
    );
  }
}
