import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeUploadImageSuccessState ||
          state is HomeUploadImageErrorState ||
          state is HomeUploadImageLoadingState,
      builder: (context, state) {
        final isUploading = homeCubit.isUploadingImage;
        final imageUrl = homeCubit.profileImageUrl;

        return Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
              backgroundImage: imageUrl != null && !isUploading
                  ? NetworkImage(imageUrl)
                  : null,
              child: isUploading
                  ? const CircularProgressIndicator(
                      color: ColorsManager.primary,
                      strokeWidth: 3,
                    )
                  : imageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 55,
                      color: ColorsManager.primary,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: homeCubit.pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsManager.primary,
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
