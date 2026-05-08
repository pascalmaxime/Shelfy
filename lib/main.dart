import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/api_keys.dart';
import 'features/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation parallèle : Supabase + SharedPreferences
  final results = await Future.wait([
    Supabase.initialize(
      url: ApiKeys.supabaseUrl,
      anonKey: ApiKeys.supabaseAnonKey,
    ),
    SharedPreferences.getInstance(),
  ]);

  final prefs = results[1] as SharedPreferences;
  final savedTheme = AppThemeOption.values.firstWhere(
    (e) => e.name == (prefs.getString('app_theme') ?? ''),
    orElse: () => AppThemeOption.light,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Injecte le thème persisté sans flash au démarrage
        themeOptionProvider.overrideWith(
          (ref) => ThemeNotifier(savedTheme),
        ),
      ],
      child: const ShelfyApp(),
    ),
  );
}
