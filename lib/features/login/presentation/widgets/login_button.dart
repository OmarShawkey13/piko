import 'package:flutter/material.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';

class LoginButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.formKey,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (formKey.currentState!.validate()) {
                  homeCubit.login();
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                appTranslation().get('login'),
                style: TextStylesManager.regular16.copyWith(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
