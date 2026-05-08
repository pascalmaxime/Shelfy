import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_item.dart';
import '../../features/livres/livres_api_provider.dart';
import '../../features/livres/livres_provider.dart';
import '../shared/api_result_card.dart';
import '../shared/empty_state.dart';
import '../shared/media_card.dart';
import 'add_livre_sheet.dart';

class LivresPage extends ConsumerStatefulWidget {
  const LivresPage({super.key});

  @override
  ConsumerState<LivresPage> createState() => _LivresPageState();
}

class _LivresPageState extends ConsumerState<LivresPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _localQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _localQuery = value.toLowerCase());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(livreSearchQueryProvider.notifier).state = value.trim();
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _localQuery = '');
    ref.read(livreSearchQueryProvider.notifier).state = '';
  }

  void _openAddSheet({Livre? initial}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddLivreSheet(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final livres = ref.watch(livresProvider);
    final apiQuery = ref.watch(livreSearchQueryProvider);
    final isSearching = apiQuery.isNotEmpty;

    final localFiltered = _localQuery.isEmpty
        ? livres
        : livres
            .where((l) =>
                l.titre.toLowerCase().contains(_localQuery) ||
                (l.auteur?.toLowerCase().contains(_localQuery) ?? false))
            .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: context.canPop()
              ? BackButton(onPressed: () => context.pop())
              : null,
          title: const Text('Livres'),
          actions: [
            IconButton(
              onPressed: () => _openAddSheet(),
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un livre',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un livre...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                suffixIcon: _localQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),

        // ── Section API ───────────────────────────────────────────
        _ApiSection(
          isSearching: isSearching,
          apiQuery: apiQuery,
          onAjouter: (livre) {
            ref.read(livresProvider.notifier).ajouter(livre);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('"${livre.titre}" ajouté à ta collection !'),
              action: SnackBarAction(
                label: 'Voir',
                onPressed: () => context.push('/detail', extra: livre),
              ),
            ));
          },
        ),

        // ── Ma collection ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ma collection',
                    style: Theme.of(context).textTheme.titleLarge),
                if (livres.isNotEmpty)
                  Text(
                    '${livres.length} livre${livres.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ),

        if (livres.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              titre: 'Aucun livre pour l\'instant',
              sousTitre: 'Appuie sur + pour ajouter ton premier livre.',
            ),
          )
        else if (localFiltered.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.search_off,
              titre: 'Aucun résultat',
              sousTitre: 'Essaie un autre terme de recherche.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 270,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final livre = localFiltered[i];
                  return MediaCard(
                    item: livre,
                    onTap: () => context.push('/detail', extra: livre),
                    onToggleStatut: () =>
                        ref.read(livresProvider.notifier).toggleStatut(livre.id),
                    onToggleSouhaits: () =>
                        ref.read(livresProvider.notifier).toggleSouhaits(livre.id),
                    onDelete: () =>
                        ref.read(livresProvider.notifier).supprimer(livre.id),
                    onChangerNote: (note) =>
                        ref.read(livresProvider.notifier).changerNote(livre.id, note),
                  );
                },
                childCount: localFiltered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _ApiSection extends ConsumerWidget {
  const _ApiSection({
    required this.isSearching,
    required this.apiQuery,
    required this.onAjouter,
  });

  final bool isSearching;
  final String apiQuery;
  final void Function(Livre livre) onAjouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (isSearching) {
      final results = ref.watch(livreSearchResultsProvider);
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Text('Résultats Google Books pour "$apiQuery"',
                  style: theme.textTheme.titleLarge),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            results.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator()))),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorTile(message: e.toString())),
              data: (items) => items.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                          icon: Icons.search_off,
                          titre: 'Aucun résultat Google Books'))
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        mainAxisExtent: 250,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final r = items[i];
                          return ApiResultCard(
                            titre: r.titre,
                            sousTitre: r.auteur,
                            annee: r.annee,
                            imageUrl: r.imageUrl,
                            typeIcon: Icons.menu_book_outlined,
                            onAjouter: () => onAjouter(r.toLivre()),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    final trending = ref.watch(trendingLivresProvider);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Text('Tendances actuelles',
                style: theme.textTheme.titleLarge),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: trending.when(
              loading: () => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _ErrorTile(message: e.toString()),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Suggestions non disponibles pour le moment.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final r = items[i];
                          return SizedBox(
                            width: 150,
                            child: ApiResultCard(
                              titre: r.titre,
                              sousTitre: r.auteur,
                              annee: r.annee,
                              imageUrl: r.imageUrl,
                              typeIcon: Icons.menu_book_outlined,
                              onAjouter: () => onAjouter(r.toLivre()),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isQuota = message.contains('429') || message.contains('Quota');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isQuota ? Icons.key_off_outlined : Icons.wifi_off_outlined,
            color: cs.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isQuota
                  ? 'Quota Google Books dépassé. Ajoute une clé API dans\nlib/core/config/api_keys.dart → googleBooks'
                  : 'Impossible de charger les données. Vérifie ta connexion.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
