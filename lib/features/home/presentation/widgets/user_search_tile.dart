import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/features/chat/presentation/screen/chat_screen.dart';

class UserSearchTile extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const UserSearchTile({super.key, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) => state is HomeChangeScaleState,
      builder: (context, state) {
        final cubit = homeCubit;
        final isItemActive = cubit.activeId == user.uid;

        return GestureDetector(
          onTapDown: (_) => cubit.changeScale(user.uid, 0.97),
          onTapUp: (_) => cubit.changeScale(user.uid, 1.0),
          onTapCancel: () => cubit.changeScale(user.uid, 1.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<Widget>(
                builder: (_) => ChatScreen(user: user),
              ),
            );
          },
          child: AnimatedScale(
            scale: isItemActive ? cubit.scale : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: ColorsManager.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [ColorsManager.primary, ColorsManager.secondary],
                    ),
                  ),
                  child: PrimaryCircleAvatar(
                    imageUrl: user.photoUrl,
                    name: user.displayName.isNotEmpty
                        ? user.displayName
                        : user.username,
                    radius: 28,
                    iconSize: 32,
                    backgroundColor: isDark
                        ? ColorsManager.darkCard
                        : Colors.white,
                  ),
                ),
                title: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName
                      : user.username,
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "@${user.username}",
                  style: TextStylesManager.regular14.copyWith(
                    color: ColorsManager.textSecondary,
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
            ),
          ),
        );
      },
    );
  }
}
