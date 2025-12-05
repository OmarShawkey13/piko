import 'package:flutter/material.dart';
import 'package:piko/features/complete_profile/presentation/screen/complete_profile_screen.dart';
import 'package:piko/features/entry/presentation/screen/entry_screen.dart';
import 'package:piko/features/home/presentation/screen/home_screen.dart';
import 'package:piko/features/home/presentation/widgets/search_screen.dart';
import 'package:piko/features/login/presentation/screen/login_screen.dart';
import 'package:piko/features/on_boarding/presentation/screen/on_boarding_screen.dart';
import 'package:piko/features/settings/presentation/screen/settings_screen.dart';
import 'package:piko/features/settings/presentation/widgets/edit_profile_screen.dart';

class Routes {
  static const String enterRoute = "/enterRoute";
  static const String onBoarding = "/onBoarding";
  static const String login = "/login";
  static const String completeProfile = "/completeProfile";
  static const String home = "/home";
  static const String settings = "/settings";
  static const String editProfile = "/editProfile";
  static const String search = "/search";

  static Map<String, WidgetBuilder> get routes => {
    enterRoute: (context) => const EntryScreen(),
    onBoarding: (context) => const OnBoardingScreen(),
    login: (context) => LoginScreen(),
    completeProfile: (context) => const CompleteProfileScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const SettingsScreen(),
    editProfile: (context) => const EditProfileScreen(),
    search: (context) => const SearchScreen(),
  };
}
