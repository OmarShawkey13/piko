import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class SearchStatusView extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color? color;

  const SearchStatusView({
    super.key,
    required this.icon,
    required this.text,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: (color ?? ColorsManager.primary).withValues(alpha: 0.2),
          ),
          verticalSpace16,
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStylesManager.medium16.copyWith(
              color: ColorsManager.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
