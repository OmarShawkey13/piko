import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      buildWhen: (_, state) => state is AuthShowPasswordUpdatedState,
      builder: (context, state) {
        return PrimaryTextFormField(
          controller: authCubit.passwordController,
          obscureText: !authCubit.isShowPassword,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            const pattern = r'^(?=.*[A-Za-z])(?=.*\d).{8,}$';
            if (!RegExp(pattern).hasMatch(value ?? "")) {
              return appTranslation().get('please_enter_password');
            }
            return null;
          },
          hintText: appTranslation().get('password'),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: ColorsManager.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              authCubit.isShowPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorsManager.primary,
            ),
            onPressed: authCubit.togglePasswordVisibility,
          ),
          filled: false,
        );
      },
    );
  }
}
