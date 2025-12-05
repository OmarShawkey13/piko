import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';

class OnBoardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int length;

  const OnBoardingIndicator({
    super.key,
    required this.currentIndex,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? null
                : ColorsManager.primary.withValues(alpha: .3),
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff4A56E2), Color(0xff6C63FF)],
                  )
                : null,
          ),
        );
      }),
    );
  }
}
