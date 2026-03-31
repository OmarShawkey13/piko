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

  final UserRepository userRepo = UserRepository();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  bool _isShowPassword = false;

  bool get isShowPassword => _isShowPassword;

  void togglePasswordVisibility() {
    _isShowPassword = !_isShowPassword;
    emit(AuthShowPasswordUpdatedState());
  }

  Future<void> login() async {
    emit(AuthLoginLoadingState());
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final User? user = await _signInUser(email, password);
      if (user != null) {
        final refreshed = await _reloadUser(user);
        await OneSignal.login(refreshed.uid);
        CacheHelper.saveData(key: 'isProfileCompleted', value: true);
        emit(AuthLoginSuccessState(refreshed, false));
        return;
      }
      final newUser = await _registerUser(email, password);
      await _createUserInFirestore(newUser);
      await OneSignal.login(newUser.uid);
      emit(AuthLoginSuccessState(newUser, true));
    } on FirebaseAuthException catch (e) {
      emit(AuthLoginErrorState(e.message ?? "Authentication failed."));
    } catch (e) {
      emit(AuthLoginErrorState(e.toString()));
    }
  }

  Future<User?> _signInUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return null;
      rethrow;
    }
  }

  Future<User> _registerUser(String email, String password) async {
    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user!;
  }

  Future<User> _reloadUser(User user) async {
    await user.reload();
    return FirebaseAuth.instance.currentUser!;
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
    await userRepo.createUser(userModel);
  }

  String? profileImageUrl;
  bool isUploadingImage = false;

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      emit(AuthUploadImageLoadingState());
      isUploadingImage = true;
      final uploadedUrl = await _uploadToCloudinary(File(image.path));
      profileImageUrl = uploadedUrl;
      isUploadingImage = false;
      emit(AuthUploadImageSuccessState(uploadedUrl));
    } catch (e) {
      isUploadingImage = false;
      emit(AuthUploadImageErrorState(e.toString()));
    }
  }

  Future<String> _uploadToCloudinary(File file) async {
    const cloudName = "dvv07qlxn";
    const uploadPreset = "userProfile";
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));
    final response = await request.send();
    final result = await response.stream.bytesToString();
    final jsonData = json.decode(result);
    return jsonData["secure_url"];
  }

  Future<void> saveProfile() async {
    final displayName = displayNameController.text.trim();
    if (displayName.isEmpty) {
      emit(AuthCompleteProfileErrorState("Display name is required"));
      return;
    }
    emit(AuthCompleteProfileLoadingState());
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await userRepo.updateUser(uid, {
        "displayName": displayName,
        "photoUrl": profileImageUrl ?? "",
        "bio": "Hi there! I'm using Piko.",
      });
      CacheHelper.saveData(key: 'isProfileCompleted', value: true);
      emit(AuthCompleteProfileSuccessState());
    } catch (e) {
      emit(AuthCompleteProfileErrorState(e.toString()));
    }
  }

  Future<String> uploadProfileImage(File file) async {
    final uploadedUrl = await _uploadToCloudinary(file);
    return uploadedUrl;
  }

  UserModel? currentUserModel;

  Future<void> cacheUser(UserModel? model) async {
    final json = jsonEncode(model!.toMap());
    await CacheHelper.saveData(key: 'userModel', value: json);
  }

  UserModel? getCachedUser() {
    final json = CacheHelper.getData(key: 'userModel');
    if (json == null) return null;
    return UserModel.fromMap(
      jsonDecode(json),
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  Future<void> getUserData() async {
    final cached = getCachedUser();
    if (cached != null) {
      currentUserModel = cached;
      emit(AuthGetUserSuccessState());
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final fresh = await userRepo.getUser(uid);
      currentUserModel = fresh;
      await cacheUser(fresh);
      emit(AuthGetUserSuccessState());
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (cached == null) {
        emit(AuthGetUserErrorState(e.toString()));
      }
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    emit(AuthEditProfileLoadingState());
    try {
      final uid = currentUserModel!.uid;
      final Map<String, dynamic> data = {};
      if (displayName != null) data['displayName'] = displayName;
      if (username != null) data['username'] = username.toLowerCase();
      if (bio != null) data['bio'] = bio;
      if (photoUrl != null) data['photoUrl'] = photoUrl;

      await userRepo.updateUser(uid, data);
      await getUserData();
      emit(AuthEditProfileSuccessState());
    } catch (e) {
      emit(AuthEditProfileErrorState(e.toString()));
    }
  }
}
