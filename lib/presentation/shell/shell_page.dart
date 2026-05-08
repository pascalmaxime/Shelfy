import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/films/films_provider.dart';
import '../../features/livres/livres_provider.dart';
import '../../features/vinyles/vinyles_provider.dart';
import '../settings/settings_sheet.dart';
import '../auth/auth_sheet.dart';
import '../auth/reset_password_sheet.dart';

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  late final StreamSubscription<AuthState> _authSub;
  StreamSubscription<Uri>? _linkSub;

  static const _destinations = [
    (icon: Icons.movie_outlined, activeIcon: Icons.movie, label: 'Films', path: '/films'),
    (icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Livres', path: '/livres'),
    (icon: Icons.album_outlined, activeIcon: Icons.album, label: 'Vinyles', path: '/vinyles'),
    (icon: Icons.collections_bookmark_outlined, activeIcon: Icons.collections_bookmark, label: 'Bibliothèque', path: '/bibliotheque'),
    (icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: 'Souhaits', path: '/souhaits'),
  ];

  static bool get _isDesktopPlatform =>
      defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android;

  @override
  void initState() {
    super.initState();

    // Écoute les changements d'auth pour charger / vider les données
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _chargerTout();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _viderTout();
      }
    });

    // Chargement initial si déjà connecté
    if (Supabase.instance.client.auth.currentUser != null) {
      Future.microtask(_chargerTout);
    }

    // Écoute des deep links (ex: shelfy://reset-password?code=xxx)
    _setupDeepLinks();
  }

  Future<void> _setupDeepLinks() async {
    final appLinks = AppLinks();

    // Lien reçu au démarrage à froid
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _handleDeepLink(initialLink);
    }

    // Liens reçus pendant que l'app tourne
    _linkSub = appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (_) {},
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'shelfy') return;

    if (uri.host == 'reset-password') {
      final code = uri.queryParameters['code'];
      if (code == null || !mounted) return;
      try {
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ResetPasswordSheet(),
          );
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  void _chargerTout() {
    ref.read(filmsProvider.notifier).charger();
    ref.read(livresProvider.notifier).charger();
    ref.read(vinylesProvider.notifier).charger();
  }

  void _viderTout() {
    ref.read(filmsProvider.notifier).vider();
    ref.read(livresProvider.notifier).vider();
    ref.read(vinylesProvider.notifier).vider();
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  void _openSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Dialog(
        child: SizedBox(width: 400, child: SettingsSheet()),
      ),
    );
  }

  void _openAuth(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Dialog(
        child: SizedBox(width: 420, child: AuthSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktopPlatform;
    final user = ref.watch(currentUserProvider);
    final isConnecte = user != null;

    if (isDesktop) {
      final selectedIndex = _selectedIndex(context);
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(_destinations[i].path),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  'assets/images/Logo-Shelfy.png',
                  height: 48,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openAuth(context),
                          icon: Icon(
                            isConnecte
                                ? Icons.account_circle
                                : Icons.account_circle_outlined,
                            color: isConnecte
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          tooltip: isConnecte
                              ? user.email ?? 'Mon compte'
                              : 'Se connecter',
                        ),
                        IconButton(
                          onPressed: () => _openSettings(context),
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: 'Paramètres',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.activeIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(body: widget.child);
  }
}
