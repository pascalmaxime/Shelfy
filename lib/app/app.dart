import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/theme/theme_provider.dart';
import 'router.dart';
import 'theme.dart';

class ShelfyApp extends ConsumerWidget {
  const ShelfyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeOption = ref.watch(themeOptionProvider);

    return MaterialApp.router(
      title: 'Shelfy',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeOption == AppThemeOption.system
          ? ThemeMode.system
          : themeOption == AppThemeOption.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
