import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/on_boarding/data/models/onboarding_item.dart';

class OnBoardingPageItem extends StatelessWidget {
  final OnBoardingItem item;

  const OnBoardingPageItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          item.image,
          width: 260,
          height: 260,
          fit: BoxFit.contain,
        ),
        verticalSpace30,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStylesManager.bold22.copyWith(
              color: ColorsManager.primary,
            ),
          ),
        ),
        verticalSpace16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: TextStylesManager.regular14.copyWith(
              color: homeCubit.isDarkMode
                  ? ColorsManager.darkTextSecondary
                  : ColorsManager.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
