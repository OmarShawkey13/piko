import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) => homeCubit.searchUsername(value),
        style: TextStylesManager.medium16.copyWith(
          color: isDark ? Colors.white : ColorsManager.lightTextPrimary,
        ),
        decoration: InputDecoration(
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
