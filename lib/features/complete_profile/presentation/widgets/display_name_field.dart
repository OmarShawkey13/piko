import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : ColorsManager.lightCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: ColorsManager.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextFormField(
        controller: authCubit.displayNameController,
        keyboardType: TextInputType.name,
        validator: (value) => value!.isEmpty
            ? appTranslation().get('please_enter_display_name')
            : null,
        style: TextStylesManager.regular14.copyWith(
          color: ColorsManager.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: appTranslation().get('display_name'),
          hintStyle: TextStylesManager.regular14.copyWith(
            color: ColorsManager.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.person_outline,
            color: ColorsManager.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
