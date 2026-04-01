import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/constants/primary/primary_circle_avatar.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      buildWhen: (_, state) =>
          state is AuthUploadImageSuccessState ||
          state is AuthUploadImageErrorState ||
          state is AuthUploadImageLoadingState,
      builder: (context, state) {
        final isUploading = state is AuthUploadImageLoadingState;
        final imageUrl = authCubit.profileImageUrl;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: PrimaryCircleAvatar(
                imageUrl: imageUrl,
                radius: 60,
                iconSize: 65,
                backgroundColor: ColorsManager.primary.withValues(alpha: 0.05),
                fallbackIcon: Icons.person_rounded,
                child: isUploading
                    ? const LoadingIndicator(
                        size: 30,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: authCubit.pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsManager.primary,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
