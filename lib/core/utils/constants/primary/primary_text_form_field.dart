import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';

class PrimaryTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final String? prefixText;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  const PrimaryTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.prefixText,
    this.filled = true,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.contentPadding,
    this.style,
    this.hintStyle,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDarkMode;
    return Container(
      decoration: (border == null && !filled)
          ? BoxDecoration(
              color: fillColor ?? (ColorsManager.cardColor),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            )
          : null,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        style:
            style ??
            TextStylesManager.medium16.copyWith(
              color: ColorsManager.textPrimary,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              hintStyle ??
              TextStylesManager.regular14.copyWith(
                color: ColorsManager.textSecondary.withValues(alpha: 0.5),
              ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefixText: prefixText,
          filled: border != null || filled,
          fillColor:
              fillColor ??
              (border != null
                  ? (isDark
                        ? ColorsManager.white.withValues(alpha: 0.05)
                        : Colors.grey[50])
                  : Colors.transparent),
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
          border:
              border ??
              (filled
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none),
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
        ),
      ),
    );
  }
}
