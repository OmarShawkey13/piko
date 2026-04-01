import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryTextFormField(
      controller: authCubit.displayNameController,
      keyboardType: TextInputType.name,
      validator: (value) => value!.isEmpty
          ? appTranslation().get('please_enter_display_name')
          : null,
      hintText: appTranslation().get('display_name'),
      prefixIcon: const Icon(
        Icons.person_outline,
        color: ColorsManager.primary,
      ),
      filled: false,
    );
  }
}
