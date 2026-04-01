import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.textColor,
    this.iconColor,
    this.onTap,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(24) : Radius.zero,
      bottom: isLast ? const Radius.circular(24) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (iconColor ?? ColorsManager.primary).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? ColorsManager.primary,
                      size: 22,
                    ),
                  ),
                  horizontalSpace16,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStylesManager.medium16.copyWith(
                        color:
                            textColor ??
                            (isDark
                                ? ColorsManager.white
                                : ColorsManager.lightTextPrimary),
                      ),
                    ),
                  ),
                  if (value != null) ...[
                    Text(
                      value!,
                      style: TextStylesManager.regular14.copyWith(
                        color: ColorsManager.lightTextSecondary,
                      ),
                    ),
                    horizontalSpace8,
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: ColorsManager.lightTextSecondary.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 62, right: 16),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark
                      ? ColorsManager.white.withValues(alpha: 0.08)
                      : ColorsManager.black.withValues(alpha: 0.05),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
