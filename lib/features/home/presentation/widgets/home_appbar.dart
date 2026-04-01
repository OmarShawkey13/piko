import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeCubit.isDarkMode;
        return BlocBuilder<AuthCubit, AuthStates>(
          buildWhen: (_, state) =>
              state is AuthGetUserSuccessState ||
              state is AuthGetUserErrorState ||
              state is AuthGetUserLoadingState,
          builder: (context, authState) {
            final user = authCubit.currentUserModel;
            return PrimaryAppBar(
              backgroundColor: isDark
                  ? ColorsManager.darkBackground
                  : ColorsManager.lightBackground,
              elevation: 0,
              centerTitle: false,
              showBackButton: false,
              titleWidget: Text(
                appTranslation().get("app_name"),
                style: TextStylesManager.bold24.copyWith(
                  color: ColorsManager.primary,
                  letterSpacing: -1,
                ),
              ),
              actions: [
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
                    child: PrimaryCircleAvatar(
                      imageUrl: user?.photoUrl,
                      radius: 18,
                      iconSize: 20,
                      backgroundColor: ColorsManager.primary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
