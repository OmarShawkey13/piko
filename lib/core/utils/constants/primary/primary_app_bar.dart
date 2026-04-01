import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const PrimaryAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      bottom: bottom,
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStylesManager.bold18.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                )
              : null),
      centerTitle: centerTitle,
      actions: actions,
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  onPressed: () => context.pop,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: ColorsManager.textPrimary,
                    size: 20,
                  ),
                )
              : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}
