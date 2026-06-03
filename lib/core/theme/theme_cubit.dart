import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manage application theme state (Light, Dark, System).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Toggle between Light and Dark mode based on current context brightness.
  void toggleTheme(Brightness currentBrightness) {
    if (currentBrightness == Brightness.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  /// Explicitly set a specific theme mode.
  void setThemeMode(ThemeMode themeMode) {
    emit(themeMode);
  }
}
