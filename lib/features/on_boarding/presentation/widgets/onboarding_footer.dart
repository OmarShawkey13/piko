import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';

class OnBoardingFooter extends StatelessWidget {
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onStart;

  const OnBoardingFooter({
    super.key,
    required this.isLast,
    required this.onSkip,
    required this.onNext,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip
          InkWell(
            onTap: onSkip,
            child: Text(
              appTranslation().get('skip'),
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.primary,
              ),
            ),
          ),

          // Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            onPressed: isLast ? onStart : onNext,
            child: isLast
                ? Text(
                    appTranslation().get("get_started"),
                    style: TextStylesManager.medium14.copyWith(
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }
}
