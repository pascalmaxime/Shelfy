import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class ShelfyApp extends StatelessWidget {
  const ShelfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shelfy',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
