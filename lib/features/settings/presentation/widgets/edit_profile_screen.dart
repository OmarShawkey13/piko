import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_button.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
    authCubit.initEditProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthEditProfileSuccessState) {
          context.pop;
          _showSnackBar(
            context,
            'تم تحديث الملف الشخصي بنجاح',
            ColorsManager.success,
          );
        }
        if (state is AuthEditProfileErrorState) {
          _showSnackBar(context, state.error, ColorsManager.error);
        }
      },
      builder: (context, state) {
        final cubit = authCubit;
        final isLoading = state is AuthEditProfileLoadingState;
        final isUploading = state is AuthUploadImageLoadingState;
        return Scaffold(
          appBar: PrimaryAppBar(
            title: appTranslation().get('edit_profile'),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    verticalSpace30,
                    _buildProfileImage(cubit, isUploading),
                    verticalSpace40,
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColorsManager.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            appTranslation().get('display_name'),
                          ),
                          verticalSpace10,
                          _buildTextField(
                            controller: cubit.displayNameController,
                            hint: 'أدخل اسمك',
                            icon: Icons.person_outline_rounded,
                          ),
                          verticalSpace20,
                          _buildSectionTitle(appTranslation().get('username')),
                          verticalSpace10,
                          _buildTextField(
                            controller: cubit.usernameController,
                            hint: '@username',
                            icon: Icons.alternate_email_rounded,
                            prefixText: '@',
                          ),
                          verticalSpace20,
                          _buildSectionTitle(appTranslation().get('bio')),
                          verticalSpace10,
                          _buildTextField(
                            controller: cubit.bioController,
                            hint: 'أخبرنا شيئاً عنك...',
                            icon: Icons.edit_note_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    verticalSpace40,
                    PrimaryButton(
                      text: appTranslation().get('save_changes'),
                      isLoading: isLoading,
                      height: 56,
                      borderRadius: 16,
                      textStyle: TextStylesManager.bold16.copyWith(
                        color: Colors.white,
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        cubit.updateProfileData();
                      },
                    ),
                    verticalSpace40,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(AuthCubit cubit, bool isUploading) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorsManager.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: PrimaryCircleAvatar(
              imageUrl: cubit.profileImageUrl,
              radius: 65,
              iconSize: 70,
              backgroundColor: ColorsManager.isDark
                  ? ColorsManager.darkCard
                  : Colors.grey[200],
              child: isUploading
                  ? Container(
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const LoadingIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                cubit.pickProfileImage();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsManager.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorsManager.cardColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStylesManager.bold14.copyWith(
        color: ColorsManager.textPrimary.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? prefixText,
  }) {
    return PrimaryTextFormField(
      controller: controller,
      maxLines: maxLines,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(
        icon,
        color: ColorsManager.primary.withValues(alpha: 0.7),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: ColorsManager.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ColorsManager.primary, width: 1.5),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStylesManager.medium14.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
