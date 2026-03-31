import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = themeCubit.isDarkMode;
        final user = authCubit.currentUserModel;
        return AppBar(
          backgroundColor: isDark
              ? ColorsManager.darkBackground
              : ColorsManager.lightBackground,
          elevation: 0,
          scrolledUnderElevation: 2,
          surfaceTintColor: ColorsManager.primary,
          centerTitle: false,
          title: Text(
            appTranslation().get("app_name"),
            style: TextStylesManager.bold24.copyWith(
              color: ColorsManager.primary,
              letterSpacing: -1,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push<Object>(Routes.search),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.03),
                shape: const CircleBorder(),
              ),
              icon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white : ColorsManager.lightTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push<Object>(Routes.settings),
              child: Container(
                margin: const EdgeInsets.only(right: 16, left: 8),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorsManager.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
                  backgroundImage: (user?.photoUrl.isNotEmpty ?? false)
                      ? NetworkImage(user!.photoUrl)
                      : null,
                  child: (user?.photoUrl.isEmpty ?? true)
                      ? const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: ColorsManager.primary,
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
