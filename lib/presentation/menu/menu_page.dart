import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../settings/settings_sheet.dart';
import '../auth/auth_sheet.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const _items = [
    (
      icon: Icons.movie,
      label: 'Films',
      subtitle: 'Découvrir et gérer tes films',
      path: '/films',
      color: Colors.indigo,
    ),
    (
      icon: Icons.menu_book,
      label: 'Livres',
      subtitle: 'Ta collection de livres',
      path: '/livres',
      color: Colors.teal,
    ),
    (
      icon: Icons.album,
      label: 'Vinyles',
      subtitle: 'Tes vinyles préférés',
      path: '/vinyles',
      color: Colors.deepPurple,
    ),
    (
      icon: Icons.collections_bookmark,
      label: 'Ma bibliothèque',
      subtitle: 'Tout ce que tu possèdes',
      path: '/bibliotheque',
      color: Colors.orange,
    ),
    (
      icon: Icons.favorite,
      label: 'Liste de souhaits',
      subtitle: 'Ce que tu veux acquérir',
      path: '/souhaits',
      color: Colors.pink,
    ),
  ];

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  void _openAuth(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AuthSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelfy'),
        centerTitle: true,
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          for (final item in _items)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(item.path),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: item.color.withValues(alpha: 0.15),
                        child: Icon(item.icon, color: item.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
