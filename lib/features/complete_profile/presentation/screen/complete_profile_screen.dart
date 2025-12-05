import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/complete_profile/presentation/widgets/display_name_field.dart';
import 'package:piko/features/complete_profile/presentation/widgets/profile_image_picker.dart';
import 'package:piko/features/complete_profile/presentation/widgets/save_button.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = homeCubit.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: isDark
            ? ColorsManager.darkTextPrimary
            : ColorsManager.lightTextPrimary,
        title: Text(
          appTranslation().get('complete_profile'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          children: [
            const ProfileImagePicker(),
            verticalSpace20,
            const DisplayNameField(),
            verticalSpace40,
            BlocConsumer<HomeCubit, HomeStates>(
              buildWhen: (_, state) =>
                  state is HomeCompleteProfileSuccessState ||
                  state is HomeCompleteProfileErrorState ||
                  state is HomeCompleteProfileLoadingState,
              listener: (context, state) {
                if (state is HomeCompleteProfileSuccessState) {
                  context.pushReplacement<Object>(Routes.home);
                }
              },
              builder: (context, state) {
                return SaveButton(
                  isLoading: state is HomeCompleteProfileLoadingState,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
