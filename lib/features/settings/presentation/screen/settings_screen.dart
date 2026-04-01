import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_button.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/settings/presentation/widgets/profile_header.dart';
import 'package:piko/features/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final user = authCubit.currentUserModel;
        final isDark = themeCubit.isDarkMode;

        if (user == null) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: PrimaryAppBar(
                  elevation: 0,
                  title: appTranslation().get('settings'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      verticalSpace20,
                      ProfileHeader(user: user, isDark: isDark),
                      verticalSpace40,

                      _buildSettingsGroup(
                        isDark: isDark,
                        children: [
                          SettingsTile(
                            isDark: isDark,
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

                      _buildSettingsGroup(
                        isDark: isDark,
                        children: [
                          SettingsTile(
                            isDark: isDark,
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
                            onTap: () => _showLogoutDialog(context, isDark),
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
        );
      },
    );
  }

  Widget _buildSettingsGroup({
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorsManager.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          appTranslation().get('logout'),
          style: TextStylesManager.bold18,
        ),
        content: Text(
          "Are you sure you want to sign out of your account?",
          style: TextStylesManager.regular14.copyWith(
            color: isDark
                ? ColorsManager.darkTextSecondary
                : ColorsManager.lightTextSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => context.pop,
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
          ),
          PrimaryButton(
            width: null,
            text: "Logout",
            backgroundColor: ColorsManager.error,
            borderRadius: 12,
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                if (!context.mounted) return;
                context.pushReplacement<Object>(Routes.login);
              });
            },
          ),
        ],
      ),
    );
  }
}
