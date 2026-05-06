import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeOption { light, dark, grey }

final themeOptionProvider = StateProvider<AppThemeOption>(
  (ref) => AppThemeOption.light,
);
