import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthShowPasswordUpdatedState extends AuthStates {}

class AuthLoginLoadingState extends AuthStates {}

class AuthLoginSuccessState extends AuthStates {
  final User? user;
  final bool newUser;

  AuthLoginSuccessState(this.user, this.newUser);
}

class AuthLoginErrorState extends AuthStates {
  final String error;

  AuthLoginErrorState(this.error);
}

class AuthUploadImageLoadingState extends AuthStates {}

class AuthUploadImageSuccessState extends AuthStates {
  final String imageUrl;

  AuthUploadImageSuccessState(this.imageUrl);
}

class AuthUploadImageErrorState extends AuthStates {
  final String error;

  AuthUploadImageErrorState(this.error);
}

class AuthCompleteProfileLoadingState extends AuthStates {}

class AuthCompleteProfileSuccessState extends AuthStates {}

class AuthCompleteProfileErrorState extends AuthStates {
  final String error;

  AuthCompleteProfileErrorState(this.error);
}

class AuthEditProfileLoadingState extends AuthStates {}

class AuthEditProfileSuccessState extends AuthStates {}

class AuthEditProfileErrorState extends AuthStates {
  final String error;

  AuthEditProfileErrorState(this.error);
}

class AuthGetUserLoadingState extends AuthStates {}

class AuthGetUserSuccessState extends AuthStates {}

class AuthGetUserErrorState extends AuthStates {
  final String error;

  AuthGetUserErrorState(this.error);
}
