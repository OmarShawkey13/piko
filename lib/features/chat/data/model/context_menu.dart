import 'package:flutter/material.dart';

class ContextMenuAndroid {
  final IconData icon;

  final String label;

  final VoidCallback? onTap;

  final List<ContextMenuAndroid>? subMenu;

  final bool isDestructive;

  ContextMenuAndroid({
    required this.icon,
    required this.label,
    this.onTap,
    this.subMenu,
    this.isDestructive = false,
  });

  bool get hasSubMenu => subMenu != null && subMenu!.isNotEmpty;
}
