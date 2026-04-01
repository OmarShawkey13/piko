import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final double? value;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.5,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          value: value,
          color: color ?? ColorsManager.primary,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
