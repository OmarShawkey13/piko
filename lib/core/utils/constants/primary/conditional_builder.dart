import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  final bool condition;

  final WidgetBuilder builder;

  final WidgetBuilder? fallback;

  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder(context);
    }
    return fallback?.call(context) ?? const SizedBox.shrink();
  }
}
