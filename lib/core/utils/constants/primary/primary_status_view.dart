import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class PrimaryStatusView extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const PrimaryStatusView({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                color: ColorsManager.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
