import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/utils/constants/translations.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/main.dart';

ThemeCubit get themeCubit => ThemeCubit.get(navigatorKey.currentContext!);

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitialState());

  static ThemeCubit get(BuildContext context) => BlocProvider.of(context);

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void changeTheme({bool? fromShared}) {
    _isDarkMode = fromShared ?? !_isDarkMode;
    CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
    emit(ThemeChangeThemeState());
  }

  bool _isArabicLang = false;
  TranslationModel? _translationModel;

  bool get isArabicLang => _isArabicLang;

  TranslationModel? get translationModel => _translationModel;

  Future<void> changeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      if (_isArabicLang == isArabic && _translationModel != null) {
        emit(ThemeLanguageUpdatedState());
        return;
      }
      emit(ThemeLanguageLoadingState());
      final model = TranslationModel.fromJson(json.decode(translations));
      _isArabicLang = isArabic;
      _translationModel = model;
      emit(ThemeLanguageUpdatedState());
    } catch (e) {
      emit(ThemeLanguageErrorState(e.toString()));
    }
  }

  Future<void> toggleLanguage() async {
    try {
      emit(ThemeLanguageLoadingState());
      final newLang = !_isArabicLang;
      final jsonString = await rootBundle.loadString(
        'assets/translations/${newLang ? 'ar' : 'en'}.json',
      );
      _translationModel = TranslationModel.fromJson(json.decode(jsonString));
      _isArabicLang = newLang;
      await CacheHelper.saveData(
        key: 'isArabicLang',
        value: _isArabicLang,
      );
      emit(ThemeLanguageUpdatedState());
    } catch (e) {
      emit(ThemeLanguageErrorState(e.toString()));
    }
  }
}
