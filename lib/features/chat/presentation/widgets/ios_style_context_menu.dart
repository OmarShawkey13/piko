import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/chat/data/model/context_menu.dart';

class IosStyleContextMenu extends StatefulWidget {
  final Widget child;
  final List<ContextMenuAndroid> actions;
  final bool? isDark;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? dividerColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;
  final double? textSize;
  final double? iconSize;

  const IosStyleContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.isDark,
    this.textStyle,
    this.backgroundColor,
    this.dividerColor,
    this.iconColor,
    this.contentPadding,
    this.textSize,
    this.iconSize,
  });

  @override
  State<IosStyleContextMenu> createState() => _IosStyleContextMenuState();
}

class _IosStyleContextMenuState extends State<IosStyleContextMenu>
    with TickerProviderStateMixin {
  late AnimationController childController;
  late Animation<double> childOpacity;
  late AnimationController menuController;
  late List<Animation<double>> actionAnimations;
  late List<List<ContextMenuAndroid>> menuStack;

  @override
  void initState() {
    super.initState();
    menuStack = [widget.actions];
    initChildAnimation();
    initMenuAnimation();
    startAnimations();
  }

  void initChildAnimation() {
    childController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    childOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: childController, curve: Curves.easeInOut),
    );
  }

  void initMenuAnimation() {
    try {
      menuController.dispose();
    } catch (_) {}
    final duration = Duration(
      milliseconds: min(600, 80 * menuStack.last.length),
    );
    menuController = AnimationController(vsync: this, duration: duration);
    actionAnimations = List.generate(menuStack.last.length, (index) {
      final start = index / menuStack.last.length;
      final end = (index + 1) / menuStack.last.length;
      return CurvedAnimation(
        parent: menuController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
  }

  void startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      await childController.forward();
      await menuController.forward();
    });
  }

  @override
  void dispose() {
    childController.dispose();
    menuController.dispose();
    super.dispose();
  }

  void openSubMenu(List<ContextMenuAndroid> subMenu) {
    setState(() {
      menuStack.add(subMenu);
      initMenuAnimation();
      menuController.forward(from: 0);
    });
  }

  void closeSubMenu() {
    if (menuStack.length > 1) {
      setState(() {
        menuStack.removeLast();
        initMenuAnimation();
        menuController.forward(from: 0);
      });
    }
  }

  TextStyle getTextStyle(BuildContext context, bool isDelete) {
    final baseColor = isDelete
        ? Colors.red
        : widget.textStyle?.color ??
              (widget.isDark ?? false ? Colors.white : Colors.black);
    final fontSize = widget.textSize ?? 16;
    return widget.textStyle?.copyWith(
          color: baseColor,
          fontSize: fontSize,
          fontWeight: isDelete ? FontWeight.w500 : FontWeight.normal,
        ) ??
        TextStyle(
          color: baseColor,
          fontSize: fontSize,
          fontWeight: isDelete ? FontWeight.w500 : FontWeight.normal,
        );
  }

  Color getIconColor(bool isDelete) {
    return isDelete
        ? Colors.red
        : widget.iconColor ??
              (widget.isDark ?? false ? Colors.white : Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final currentMenu = menuStack.last;

    return GestureDetector(
      onTap: () async {
        await menuController.reverse();
        await childController.reverse();
        if (context.mounted) context.pop;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
            GestureDetector(
              onTap: () {},
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: childController,
                          curve: Curves.easeInExpo,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: childOpacity,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width *
                                0.8, // ⬅ يمنع زيادة العرض
                            maxHeight:
                                MediaQuery.of(context).size.height *
                                0.4, // ⬅ يمنع زيادة الطول
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                    verticalSpace12,
                    Padding(
                      padding:
                          widget.contentPadding ??
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          width: 280,
                          decoration: BoxDecoration(
                            color: widget.isDark ?? false
                                ? Colors.black.withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          // REMOVED Flexible here
                          child: SingleChildScrollView(
                            // <--- This is now the direct child of Container
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (menuStack.length > 1)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.arrow_back_ios_new_outlined,
                                    ),
                                    title: const Text("Back"),
                                    onTap: closeSubMenu,
                                  ),
                                ...List.generate(currentMenu.length, (index) {
                                  final action = currentMenu[index];
                                  final isDelete = action.label
                                      .toLowerCase()
                                      .contains('delete');
                                  return FadeTransition(
                                    opacity: actionAnimations[index],
                                    child: SlideTransition(
                                      position: actionAnimations[index].drive(
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.1),
                                          end: Offset.zero,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if (action.hasSubMenu) {
                                                openSubMenu(action.subMenu!);
                                              } else {
                                                await menuController.reverse();
                                                await childController.reverse();
                                                if (context.mounted) {
                                                  context.pop;
                                                  action.onTap?.call();
                                                }
                                              }
                                            },
                                            borderRadius: index == 0
                                                ? const BorderRadius.vertical(
                                                    top: Radius.circular(16),
                                                  )
                                                : index ==
                                                      currentMenu.length - 1
                                                ? const BorderRadius.vertical(
                                                    bottom: Radius.circular(
                                                      16,
                                                    ),
                                                  )
                                                : BorderRadius.zero,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 20,
                                                  ),
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    action.label,
                                                    style: getTextStyle(
                                                      context,
                                                      isDelete,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        action.icon,
                                                        color: getIconColor(
                                                          isDelete,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (index != currentMenu.length - 1)
                                            Divider(
                                              height: 1,
                                              color:
                                                  widget.dividerColor ??
                                                  (widget.isDark ?? false
                                                      ? Colors.white12
                                                      : Colors.grey[300]),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
