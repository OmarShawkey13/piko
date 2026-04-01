import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryTextFormField(
      controller: controller,
      onChanged: (value) => homeCubit.searchUsername(value),
      style: TextStylesManager.medium16.copyWith(
        color: isDark ? Colors.white : ColorsManager.lightTextPrimary,
      ),
      hintText: appTranslation().get('search_hint'),
      hintStyle: TextStylesManager.regular14.copyWith(
        color: ColorsManager.lightTextSecondary,
      ),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: ColorsManager.primary,
      ),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 20),
            )
          : null,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
    );
  }
}
