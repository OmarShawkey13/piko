import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = homeCubit.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextFormField(
        controller: homeCubit.passwordController,
        obscureText: !homeCubit.isShowPassword,
        obscuringCharacter: "*",
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          const pattern = r'^(?=.*[A-Za-z])(?=.*\d).{8,}$';
          if (!RegExp(pattern).hasMatch(value ?? "")) {
            return appTranslation().get('please_enter_password');
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: appTranslation().get('password'),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: ColorsManager.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              homeCubit.isShowPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorsManager.primary,
            ),
            onPressed: homeCubit.togglePasswordVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
