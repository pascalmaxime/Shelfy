import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeOption { light, dark, system }

const _kThemeKey = 'app_theme';

/// Notifier qui persiste le thème choisi dans SharedPreferences.
/// Le thème est restauré au démarrage via [themeOptionProvider.overrideWith]
/// dans main.dart.
class ThemeNotifier extends StateNotifier<AppThemeOption> {
  ThemeNotifier(super.initial);

  Future<void> set(AppThemeOption option) async {
    state = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, option.name);
  }
}

final themeOptionProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeOption>(
  (ref) => ThemeNotifier(AppThemeOption.light), // remplacé par override dans main
);
