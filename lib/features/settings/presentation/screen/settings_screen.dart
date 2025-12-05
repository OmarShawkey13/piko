import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/settings/presentation/widgets/profile_header.dart';
import 'package:piko/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:piko/features/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeGetUserLoadingState ||
          state is HomeGetUserSuccessState ||
          state is HomeGetUserErrorState ||
          state is HomeChangeThemeState ||
          state is HomeLanguageLoadingState ||
          state is HomeLanguageUpdatedState,
      builder: (_, state) {
        final user = homeCubit.currentUserModel;
        final isDark = homeCubit.isDarkMode;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              appTranslation().get('settings'),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(user: user, isDark: isDark),
                verticalSpace30,
                SettingsSectionTitle(
                  appTranslation().get('preferences'),
                  isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                ),
                SettingsTile(
                  icon: Icons.brightness_6,
                  iconColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  textColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  label: appTranslation().get('change_theme'),
                  value: isDark
                      ? appTranslation().get('theme_dark')
                      : appTranslation().get('theme_light'),
                  onTap: () => homeCubit.changeTheme(),
                ),
                SettingsTile(
                  icon: Icons.language,
                  label: appTranslation().get('change_language'),
                  iconColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  textColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  value: homeCubit.isArabicLang
                      ? appTranslation().get('language_arabic')
                      : appTranslation().get('language_english'),
                  onTap: () async {
                    final isArabic = !homeCubit.isArabicLang;
                    final jsonString = await rootBundle.loadString(
                      'assets/translations/${isArabic ? 'ar' : 'en'}.json',
                    );
                    homeCubit.changeLanguage(
                      isArabic: isArabic,
                      translations: jsonString,
                    );
                    CacheHelper.saveData(
                      key: 'isArabicLang',
                      value: isArabic,
                    );
                  },
                ),
                verticalSpace20,
                SettingsSectionTitle(
                  appTranslation().get('account'),
                  isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                ),
                SettingsTile(
                  icon: Icons.person_outline,
                  iconColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  textColor: isDark
                      ? ColorsManager.darkTextPrimary
                      : ColorsManager.lightTextPrimary,
                  label: appTranslation().get('edit_profile'),
                  onTap: () {
                    context.push<Object>(Routes.editProfile);
                  },
                ),
                SettingsTile(
                  icon: Icons.logout,
                  label: appTranslation().get('logout'),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((_) {
                      if (!context.mounted) return;
                      context.pushReplacement<Object>(Routes.login);
                    });
                  },
                ),
                verticalSpace40,
              ],
            ),
          ),
        );
      },
    );
  }
}
