import 'package:flutter/material.dart';
import 'package:piko/core/theme/text_styles.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const SettingsSectionTitle(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStylesManager.regular14.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
