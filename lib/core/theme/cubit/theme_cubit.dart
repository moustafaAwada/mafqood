import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/core/theme/cubit/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  // Starts globally as Light Theme by default
  ThemeCubit() : super(ThemeState(isDarkMode: false));

  void toggleTheme() {
    emit(ThemeState(isDarkMode: !state.isDarkMode));
  }

  void setTheme(bool isDark) {
    if (state.isDarkMode != isDark) {
      emit(ThemeState(isDarkMode: isDark));
    }
  }
}
