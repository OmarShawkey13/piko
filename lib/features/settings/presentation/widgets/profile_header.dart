import 'package:flutter/material.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ColorsManager.primary,
                ColorsManager.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? ColorsManager.darkBackground : Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      size: 65,
                      color: ColorsManager.primary,
                    )
                  : null,
            ),
          ),
        ),
        verticalSpace20,
        Text(
          user.displayName.isNotEmpty ? user.displayName : "No name",
          style: TextStylesManager.bold24.copyWith(
            color: isDark ? Colors.white : ColorsManager.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        verticalSpace4,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: ColorsManager.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "@${user.username}",
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
