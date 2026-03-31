import 'package:flutter/material.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/features/chat/presentation/screen/chat_screen.dart';

class UserSearchTile extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const UserSearchTile({super.key, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<Widget>(
              builder: (_) => ChatScreen(user: user),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [ColorsManager.primary, ColorsManager.secondary],
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? ColorsManager.darkCard : Colors.white,
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : null,
            child: user.photoUrl.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: ColorsManager.primary,
                  )
                : null,
          ),
        ),
        title: Text(
          user.displayName.isNotEmpty ? user.displayName : user.username,
          style: TextStylesManager.bold16.copyWith(
            color: isDark ? Colors.white : ColorsManager.darkTextPrimary,
          ),
        ),
        subtitle: Text(
          "@${user.username}",
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.lightTextSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorsManager.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.message_rounded,
            size: 18,
            color: ColorsManager.primary,
          ),
        ),
      ),
    );
  }
}
