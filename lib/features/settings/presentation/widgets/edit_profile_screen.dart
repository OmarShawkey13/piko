import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  // مخزن لينك الصورة بعد التغيير
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = homeCubit.currentUserModel!;

    _nameController.text = user.displayName;
    _usernameController.text = user.username;
    _bioController.text = user.bio;
    _photoUrl = user.photoUrl;
  }

  /// --------------------- PICK IMAGE ---------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final uploadedUrl = await homeCubit.uploadProfileImage(File(file.path));
      setState(() {
        _photoUrl = uploadedUrl; // نحفظ اللينك
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is EditProfileSuccessState) context.pop;
      },
      builder: (context, state) {
        final loading = state is EditProfileLoadingState;
        return Scaffold(
          appBar: AppBar(
            title: Text(appTranslation().get('edit_profile')),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          _photoUrl != null && _photoUrl!.isNotEmpty
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: (_photoUrl == null || _photoUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                ),
                verticalSpace30,
                _inputField(
                  appTranslation().get('display_name'),
                  _nameController,
                ),
                _inputField(
                  appTranslation().get('username'),
                  _usernameController,
                ),
                _inputField(
                  appTranslation().get('bio'),
                  _bioController,
                  maxLines: 3,
                ),
                verticalSpace20,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            homeCubit.updateProfile(
                              displayName: _nameController.text.trim(),
                              username: _usernameController.text.trim(),
                              bio: _bioController.text.trim(),
                              photoUrl: _photoUrl ?? "",
                            );
                          },
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(appTranslation().get('save_changes')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ---------------- INPUT FIELD WIDGET ----------------
  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
