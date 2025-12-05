import 'package:flutter/material.dart';
import 'package:piko/core/theme/text_styles.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? textColor;
  final Color? subTextColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.textColor,
    this.subTextColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.withValues(alpha: 0.08),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: iconColor ?? Colors.blueGrey,
        ),
        title: Text(
          label,
          style: TextStylesManager.regular16.copyWith(
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: value != null
            ? Text(
                value!,
                style: TextStylesManager.regular12.copyWith(
                  color: subTextColor,
                ),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
