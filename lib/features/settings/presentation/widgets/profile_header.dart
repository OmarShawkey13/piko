import 'package:flutter/material.dart';
import 'package:piko/core/models/user_model.dart';
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
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : null,
            child: user.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          verticalSpace10,
          Text(
            user.displayName.isNotEmpty ? user.displayName : "No name",
            style: TextStylesManager.bold20.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          verticalSpace6,
          Text(
            "@${user.username}",
            style: TextStylesManager.regular14.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
