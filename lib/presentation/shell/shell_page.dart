import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../settings/settings_sheet.dart';
import '../auth/auth_sheet.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.child});
  final Widget child;

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
                          icon: const Icon(Icons.account_circle_outlined),
                          tooltip: 'Mon compte',
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
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(body: child);
  }
}
