import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/assets_helper.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AssetsHelper.logo,
          height: 200,
          width: 200,
        ),
        Text(
          appTranslation().get('welcome_to_piko'),
          style: TextStylesManager.bold26.copyWith(
            color: ColorsManager.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace8,
        Text(
          appTranslation().get('sign_with_account'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
