import 'package:firebase_auth/firebase_auth.dart';
import 'package:piko/core/models/user_model.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeChangeThemeState extends HomeStates {}

class HomeLanguageUpdatedState extends HomeStates {}

class HomeLanguageLoadingState extends HomeStates {}

class HomeLanguageLoadedState extends HomeStates {}

class HomeLanguageErrorState extends HomeStates {
  final String error;

  HomeLanguageErrorState(this.error);
}

//login
class HomeShowPasswordUpdatedState extends HomeStates {}

class HomeLoginLoadingState extends HomeStates {}

class HomeLoginSuccessState extends HomeStates {
  final User? user;
  final bool newUser;

  HomeLoginSuccessState(this.user, this.newUser);
}

class HomeLoginErrorState extends HomeStates {
  final String error;

  HomeLoginErrorState(this.error);
}

//complete profile
class HomeUploadImageLoadingState extends HomeStates {}

class HomeUploadImageSuccessState extends HomeStates {
  final String imageUrl;

  HomeUploadImageSuccessState(this.imageUrl);
}

class HomeUploadImageErrorState extends HomeStates {
  final String error;

  HomeUploadImageErrorState(this.error);
}

class HomeCompleteProfileLoadingState extends HomeStates {}

class HomeCompleteProfileSuccessState extends HomeStates {}

class HomeCompleteProfileErrorState extends HomeStates {
  final String error;

  HomeCompleteProfileErrorState(this.error);
}

//getUserDate
class HomeGetUserLoadingState extends HomeStates {}

class HomeGetUserSuccessState extends HomeStates {}

class HomeGetUserErrorState extends HomeStates {
  final String error;

  HomeGetUserErrorState(this.error);
}

//search
class SearchInitialState extends HomeStates {}

class SearchLoadingState extends HomeStates {}

class SearchSuccessState extends HomeStates {
  final UserModel? user;

  SearchSuccessState(this.user);
}

class SearchErrorState extends HomeStates {
  final String error;

  SearchErrorState(this.error);
}

//chat
class ChatMessagesLoadingState extends HomeStates {}

class ChatMessagesSuccessState extends HomeStates {
  final List<Map<String, dynamic>> messages;

  ChatMessagesSuccessState(this.messages);
}

class ChatBackgroundChangedState extends HomeStates {}

class ChatSendSuccessState extends HomeStates {}

class ChatSendErrorState extends HomeStates {
  final String error;

  ChatSendErrorState(this.error);
}

class ChatUploadImageLoadingState extends HomeStates {}

class ChatPickImageSuccessState extends HomeStates {}

class ChatUploadImageSuccessState extends HomeStates {
  final String imageUrl;

  ChatUploadImageSuccessState(this.imageUrl);
}

class ChatUploadImageErrorState extends HomeStates {
  final String error;

  ChatUploadImageErrorState(this.error);
}

//loadChats
class HomeChatsLoadingState extends HomeStates {}

class HomeChatsSuccessState extends HomeStates {}

class HomeChatsErrorState extends HomeStates {
  final String error;

  HomeChatsErrorState(this.error);
}

//editProfile
class EditProfileLoadingState extends HomeStates {}

class EditProfileSuccessState extends HomeStates {}

class EditProfileErrorState extends HomeStates {
  final String error;

  EditProfileErrorState(this.error);
}
