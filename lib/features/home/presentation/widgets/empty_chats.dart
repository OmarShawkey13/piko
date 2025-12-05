import 'package:flutter/material.dart';
import 'package:piko/core/theme/text_styles.dart';

class EmptyChats extends StatelessWidget {
  const EmptyChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No chats yet",
        style: TextStylesManager.regular16.copyWith(
          color: Colors.grey,
        ),
      ),
    );
  }
}
