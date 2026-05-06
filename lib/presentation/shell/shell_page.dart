import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 600;

    // Desktop : rail de navigation sur la gauche, toujours visible
    if (isDesktop) {
      final selectedIndex = _selectedIndex(context);
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(_destinations[i].path),
              labelType: NavigationRailLabelType.all,
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

    // Mobile : pas de navigation persistante, juste le contenu
    // La navigation se fait depuis MenuPage avec context.push()
    return Scaffold(body: child);
  }
}
