abstract class ThemeState {}

class ThemeInitialState extends ThemeState {}

class ThemeChangeThemeState extends ThemeState {}

class ThemeLanguageUpdatedState extends ThemeState {}

class ThemeLanguageLoadingState extends ThemeState {}

class ThemeLanguageSuccessState extends ThemeState {}

class ThemeLanguageErrorState extends ThemeState {
  final String error;

  ThemeLanguageErrorState(this.error);
}
