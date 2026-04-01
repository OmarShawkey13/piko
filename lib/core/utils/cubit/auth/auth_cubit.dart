import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/network/user_repository.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/main.dart';

AuthCubit get authCubit => AuthCubit.get(navigatorKey.currentContext!);

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  final UserRepository _userRepo = UserRepository();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  bool isShowPassword = false;
  String? profileImageUrl;
  UserModel? currentUserModel;

  void togglePasswordVisibility() {
    isShowPassword = !isShowPassword;
    emit(AuthShowPasswordUpdatedState());
  }

  // --- Auth Logic ---

  Future<void> login() async {
    emit(AuthLoginLoadingState());
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      User? user;
      bool isNewUser = false;

      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: email,
              password: password,
            );
        user = credential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          final res = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
          user = res.user;
          isNewUser = true;
          await _createUserInFirestore(user!);
        } else {
          rethrow;
        }
      }

      if (user != null) {
        await user.reload();
        await OneSignal.login(user.uid);
        CacheHelper.saveData(key: 'isProfileCompleted', value: true);
        emit(AuthLoginSuccessState(user, isNewUser));
      }
    } catch (e) {
      emit(AuthLoginErrorState(e.toString()));
    }
  }

  Future<void> _createUserInFirestore(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: "",
      username: "",
      photoUrl: "",
      bio: "",
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );
    await _userRepo.createUser(userModel);
  }

  // --- Profile & Image Logic ---

  Future<void> pickProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    emit(AuthUploadImageLoadingState());
    try {
      profileImageUrl = await _uploadToCloudinary(File(image.path));
      emit(AuthUploadImageSuccessState(profileImageUrl!));
    } catch (e) {
      emit(AuthUploadImageErrorState(e.toString()));
    }
  }

  Future<String> _uploadToCloudinary(File file) async {
    final request =
        http.MultipartRequest(
            "POST",
            Uri.parse("https://api.cloudinary.com/v1_1/dvv07qlxn/image/upload"),
          )
          ..fields["upload_preset"] = "userProfile"
          ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final data = json.decode(await response.stream.bytesToString());
    return data["secure_url"];
  }

  Future<void> updateProfileData({bool isInitial = false}) async {
    isInitial
        ? emit(AuthCompleteProfileLoadingState())
        : emit(AuthEditProfileLoadingState());

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final data = {
        'displayName': displayNameController.text.trim(),
        'username': usernameController.text.trim().toLowerCase(),
        'bio': bioController.text.trim().isEmpty
            ? "Hi there! I'm using Piko."
            : bioController.text.trim(),
        'photoUrl': profileImageUrl ?? "",
      };

      await _userRepo.updateUser(uid, data);
      await getUserData();

      isInitial
          ? emit(AuthCompleteProfileSuccessState())
          : emit(AuthEditProfileSuccessState());
    } catch (e) {
      isInitial
          ? emit(AuthCompleteProfileErrorState(e.toString()))
          : emit(AuthEditProfileErrorState(e.toString()));
    }
  }

  // --- Data Management ---

  Future<void> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Load from cache first
    final cachedJson = CacheHelper.getData(key: 'userModel');
    if (cachedJson != null) {
      currentUserModel = UserModel.fromMap(jsonDecode(cachedJson), uid);
      emit(AuthGetUserSuccessState());
    }

    try {
      final freshUser = await _userRepo.getUser(uid);
      currentUserModel = freshUser;
      await CacheHelper.saveData(
        key: 'userModel',
        value: jsonEncode(freshUser!.toMap()),
      );
      emit(AuthGetUserSuccessState());
    } catch (e) {
      if (currentUserModel == null) emit(AuthGetUserErrorState(e.toString()));
    }
  }

  void initEditProfile() {
    if (currentUserModel != null) {
      displayNameController.text = currentUserModel!.displayName;
      usernameController.text = currentUserModel!.username;
      bioController.text = currentUserModel!.bio;
      profileImageUrl = currentUserModel!.photoUrl;
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    return super.close();
  }
}
