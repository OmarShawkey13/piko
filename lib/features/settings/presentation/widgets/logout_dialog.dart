import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_button.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class LogoutDialog extends StatelessWidget {
  final bool isDark;

  const LogoutDialog({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? ColorsManager.darkCard : ColorsManager.white,
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
            style: TextStyle(
              color: isDark
                  ? ColorsManager.white.withValues(alpha: 0.7)
                  : ColorsManager.lightTextSecondary,
            ),
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
    );
  }
}
