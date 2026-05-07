import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_item.dart';
import '../../features/films/films_provider.dart';
import '../../features/livres/livres_provider.dart';
import '../../features/souhaits/souhaits_provider.dart';
import '../../features/vinyles/vinyles_provider.dart';
import '../shared/empty_state.dart';
import '../shared/media_card.dart';

class SouhaitePage extends ConsumerStatefulWidget {
  const SouhaitePage({super.key});

  @override
  ConsumerState<SouhaitePage> createState() => _SouhaitePageState();
}

class _SouhaitePageState extends ConsumerState<SouhaitePage> {
  final Set<String> _selectedTypes = {'Films', 'Livres', 'Vinyles'};
  static const _types = ['Films', 'Livres', 'Vinyles'];
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filtrer par type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final type in _types)
                CheckboxListTile(
                  title: Text(type),
                  value: _selectedTypes.contains(type),
                  onChanged: (checked) {
                    setSheetState(() => setState(() {
                          if (checked == true) {
                            _selectedTypes.add(type);
                          } else if (_selectedTypes.length > 1) {
                            _selectedTypes.remove(type);
                          }
                        }));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSouhaits(MediaItem item) {
    switch (item) {
      case Film f:
        ref.read(filmsProvider.notifier).toggleSouhaits(f.id);
      case Livre l:
        ref.read(livresProvider.notifier).toggleSouhaits(l.id);
      case Vinyle v:
        ref.read(vinylesProvider.notifier).toggleSouhaits(v.id);
    }
  }

  void _toggleStatut(MediaItem item) {
    switch (item) {
      case Film f:
        ref.read(filmsProvider.notifier).toggleStatut(f.id);
      case Livre l:
        ref.read(livresProvider.notifier).toggleStatut(l.id);
      case Vinyle v:
        ref.read(vinylesProvider.notifier).toggleStatut(v.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final souhaits = ref.watch(souhaistsProvider);
    final allSelected = _selectedTypes.length == _types.length;

    final filtered = souhaits.where((item) {
      final typeOk = switch (item) {
        Film _ => _selectedTypes.contains('Films'),
        Livre _ => _selectedTypes.contains('Livres'),
        Vinyle _ => _selectedTypes.contains('Vinyles'),
      };
      if (!typeOk) return false;
      if (_query.isEmpty) return true;
      return item.titre.toLowerCase().contains(_query);
    }).toList();

    return CustomScrollView(
      slivers: [
        // ── AppBar ────────────────────────────────────────────────
        SliverAppBar.large(
          leading: context.canPop()
              ? BackButton(onPressed: () => context.pop())
              : null,
          title: const Text('Liste de souhaits'),
        ),

        // ── Contrôles ─────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverList.list(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Rechercher dans mes souhaits...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: _showFilterSheet,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, size: 18),
                        const SizedBox(width: 8),
                        Text(allSelected
                            ? 'Filtrer'
                            : _selectedTypes.join(', ')),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (souhaits.isNotEmpty)
                    Text(
                      '${souhaits.length} souhait${souhaits.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Contenu ───────────────────────────────────────────────
        if (souhaits.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.favorite_outline,
              titre: 'Aucun souhait pour l\'instant',
              sousTitre:
                  'Appuie sur ❤ sur n\'importe quel item pour l\'ajouter ici.',
            ),
          )
        else if (filtered.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.search_off,
              titre: 'Aucun résultat',
              sousTitre: 'Essaie un autre terme ou filtre.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 270,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = filtered[i];
                  return MediaCard(
                    item: item,
                    onToggleStatut: () => _toggleStatut(item),
                    // Retirer des souhaits via le cœur
                    onToggleSouhaits: () => _toggleSouhaits(item),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}
