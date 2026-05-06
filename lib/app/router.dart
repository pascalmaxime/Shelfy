import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../presentation/shell/shell_page.dart';
import '../presentation/menu/menu_page.dart';
import '../presentation/films/films_page.dart';
import '../presentation/livres/livres_page.dart';
import '../presentation/vinyles/vinyles_page.dart';
import '../presentation/bibliotheque/bibliotheque_page.dart';
import '../presentation/souhaits/souhaits_page.dart';

// Sur mobile on commence sur le menu, sur desktop directement sur Films
bool get _isMobile =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

final GoRouter appRouter = GoRouter(
  initialLocation: _isMobile ? '/' : '/films',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        // Page menu — mobile uniquement (point d'entrée)
        GoRoute(
          path: '/',
          builder: (context, state) => const MenuPage(),
        ),
        GoRoute(
          path: '/films',
          builder: (context, state) => const FilmsPage(),
        ),
        GoRoute(
          path: '/livres',
          builder: (context, state) => const LivresPage(),
        ),
        GoRoute(
          path: '/vinyles',
          builder: (context, state) => const VinylesPage(),
        ),
        GoRoute(
          path: '/bibliotheque',
          builder: (context, state) => const BibliothequePage(),
        ),
        GoRoute(
          path: '/souhaits',
          builder: (context, state) => const SouhaitePage(),
        ),
      ],
    ),
  ],
);
