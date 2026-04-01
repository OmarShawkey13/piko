import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/settings/presentation/widgets/profile_header.dart';
import 'package:piko/features/settings/presentation/widgets/settings_tile.dart';
import 'package:piko/features/settings/presentation/widgets/settings_group.dart';
import 'package:piko/features/settings/presentation/widgets/logout_dialog.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final user = authCubit.currentUserModel;
        final isDark = themeCubit.isDarkMode;
        return Scaffold(
          body: ConditionalBuilder(
            loadingState: user == null,
            successBuilder: (context) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: PrimaryAppBar(
                    title: appTranslation().get('settings'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        verticalSpace20,
                        ProfileHeader(user: user!, isDark: isDark),
                        verticalSpace40,
                        SettingsGroup(
                          isDark: isDark,
                          children: [
                            SettingsTile(
                              isDark: isDark,
                              isFirst: true,
                              icon: Icons.palette_rounded,
                              label: appTranslation().get('change_theme'),
                              value: isDark
                                  ? appTranslation().get('theme_dark')
                                  : appTranslation().get('theme_light'),
                              onTap: () => themeCubit.changeTheme(),
                            ),
                            SettingsTile(
                              isDark: isDark,
                              icon: Icons.translate_rounded,
                              label: appTranslation().get('change_language'),
                              value: themeCubit.isArabicLang
                                  ? appTranslation().get('language_arabic')
                                  : appTranslation().get('language_english'),
                              onTap: () => themeCubit.toggleLanguage(),
                              isLast: true,
                            ),
                          ],
                        ),
                        verticalSpace24,
                        SettingsGroup(
                          isDark: isDark,
                          children: [
                            SettingsTile(
                              isDark: isDark,
                              isFirst: true,
                              icon: Icons.person_rounded,
                              label: appTranslation().get('edit_profile'),
                              onTap: () =>
                                  context.push<Object>(Routes.editProfile),
                            ),
                            SettingsTile(
                              isDark: isDark,
                              icon: Icons.logout_rounded,
                              label: appTranslation().get('logout'),
                              iconColor: ColorsManager.error,
                              textColor: ColorsManager.error,
                              onTap: () => showDialog<void>(
                                context: context,
                                builder: (context) =>
                                    LogoutDialog(isDark: isDark),
                              ),
                              isLast: true,
                            ),
                          ],
                        ),
                        verticalSpace40,
                        Text(
                          "Piko Messenger",
                          style: TextStylesManager.bold14.copyWith(
                            color: ColorsManager.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          "Version 1.0.0",
                          style: TextStylesManager.regular12.copyWith(
                            color: ColorsManager.lightTextSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        verticalSpace40,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
