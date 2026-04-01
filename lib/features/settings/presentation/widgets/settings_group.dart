import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const SettingsGroup({
    super.key,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : ColorsManager.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
}
