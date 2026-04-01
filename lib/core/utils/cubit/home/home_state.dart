import 'package:piko/core/models/user_model.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeChangeScaleState extends HomeStates {}

// Search
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

// Online Status
class SetOnlineStatusSuccessState extends HomeStates {}

class SetOnlineStatusErrorState extends HomeStates {
  final String error;
  SetOnlineStatusErrorState(this.error);
}
