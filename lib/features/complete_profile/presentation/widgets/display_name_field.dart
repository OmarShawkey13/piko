import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = homeCubit.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextFormField(
        controller: homeCubit.displayNameController,
        keyboardType: TextInputType.name,
        validator: (value) => value!.isEmpty
            ? appTranslation().get('please_enter_display_name')
            : null,
        style: TextStylesManager.regular14.copyWith(
          color: isDark
              ? ColorsManager.darkTextPrimary
              : ColorsManager.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: appTranslation().get('display_name'),
          hintStyle: TextStylesManager.regular14.copyWith(
            color: isDark
                ? ColorsManager.darkTextSecondary
                : ColorsManager.lightTextSecondary,
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
