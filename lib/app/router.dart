import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/media_item.dart';
import '../presentation/shell/shell_page.dart';
import '../presentation/menu/menu_page.dart';
import '../presentation/films/films_page.dart';
import '../presentation/livres/livres_page.dart';
import '../presentation/vinyles/vinyles_page.dart';
import '../presentation/bibliotheque/bibliotheque_page.dart';
import '../presentation/souhaits/souhaits_page.dart';
import '../presentation/detail/detail_page.dart';
import '../presentation/about/about_page.dart';

bool get _isMobile =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

// ── Transitions réutilisables ─────────────────────────────────────────────────

/// Onglets : fondu rapide (150 ms) — pas de slide qui superpose.
Page<void> _tabPage({required LocalKey key, required Widget child}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      ),
    );

/// Pages poussées (détail, à propos) : fondu + légère remontée (200 ms).
Page<void> _pushPage({required LocalKey key, required Widget child}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );

// ── Router ────────────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: _isMobile ? '/' : '/films',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const MenuPage()),
        ),
        GoRoute(
          path: '/films',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const FilmsPage()),
        ),
        GoRoute(
          path: '/livres',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const LivresPage()),
        ),
        GoRoute(
          path: '/vinyles',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const VinylesPage()),
        ),
        GoRoute(
          path: '/bibliotheque',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const BibliothequePage()),
        ),
        GoRoute(
          path: '/souhaits',
          pageBuilder: (context, state) =>
              _tabPage(key: state.pageKey, child: const SouhaitePage()),
        ),
        GoRoute(
          path: '/detail',
          pageBuilder: (context, state) => _pushPage(
            key: state.pageKey,
            child: DetailPage(itemInitial: state.extra as MediaItem),
          ),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) =>
              _pushPage(key: state.pageKey, child: const AboutPage()),
        ),
      ],
    ),
  ],
);
