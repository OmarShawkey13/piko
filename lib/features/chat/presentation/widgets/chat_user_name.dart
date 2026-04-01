import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/models/user_model.dart';

class ChatUserName extends StatelessWidget {
  final UserModel user;

  const ChatUserName({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Text(
      user.displayName.isNotEmpty ? user.displayName : user.username,
      style: TextStylesManager.bold16.copyWith(
        color: ColorsManager.textPrimary,
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
