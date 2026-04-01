import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryTextFormField(
      controller: authCubit.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          value!.isEmpty ? appTranslation().get('please_enter_email') : null,
      hintText: appTranslation().get('email_address'),
      prefixIcon: const Icon(
        Icons.email_rounded,
        color: ColorsManager.primary,
      ),
      filled: false,
    );
  }
}
