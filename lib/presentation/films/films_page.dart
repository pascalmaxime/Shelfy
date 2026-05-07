import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_item.dart';
import '../../features/films/films_api_provider.dart';
import '../../features/films/films_provider.dart';
import '../shared/api_result_card.dart';
import '../shared/empty_state.dart';
import '../shared/media_card.dart';
import 'add_film_sheet.dart';

class FilmsPage extends ConsumerStatefulWidget {
  const FilmsPage({super.key});

  @override
  ConsumerState<FilmsPage> createState() => _FilmsPageState();
}

class _FilmsPageState extends ConsumerState<FilmsPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _localQuery = ''; // filtre local (collection)

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Filtre local immédiat
    setState(() => _localQuery = value.toLowerCase());
    // Debounce 500ms pour l'API
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(filmSearchQueryProvider.notifier).state = value.trim();
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _localQuery = '');
    ref.read(filmSearchQueryProvider.notifier).state = '';
  }

  void _openAddSheet({Film? initial}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddFilmSheet(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final films = ref.watch(filmsProvider);
    final apiQuery = ref.watch(filmSearchQueryProvider);
    final isSearching = apiQuery.isNotEmpty;

    final localFiltered = _localQuery.isEmpty
        ? films
        : films
            .where((f) =>
                f.titre.toLowerCase().contains(_localQuery) ||
                (f.realisateur?.toLowerCase().contains(_localQuery) ?? false))
            .toList();

    return CustomScrollView(
      slivers: [
        // ── AppBar ────────────────────────────────────────────────
        SliverAppBar.large(
          leading: context.canPop()
              ? BackButton(onPressed: () => context.pop())
              : null,
          title: const Text('Films'),
          actions: [
            IconButton(
              onPressed: () => _openAddSheet(),
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un film',
            ),
          ],
        ),

        // ── Barre de recherche ────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un film...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

        // ── Section API : Tendances ou Résultats de recherche ─────
        _ApiSection(
          isSearching: isSearching,
          apiQuery: apiQuery,
          onAjouter: (film) => _openAddSheet(initial: film),
        ),

        // ── Section locale : Ma collection ────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ma collection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (films.isNotEmpty)
                  Text(
                    '${films.length} film${films.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ),

        if (films.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.movie_outlined,
              titre: 'Aucun film pour l\'instant',
              sousTitre: 'Appuie sur + pour ajouter ton premier film.',
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
                  final film = localFiltered[i];
                  return MediaCard(
                    item: film,
                    onToggleStatut: () =>
                        ref.read(filmsProvider.notifier).toggleStatut(film.id),
                    onToggleSouhaits: () =>
                        ref.read(filmsProvider.notifier).toggleSouhaits(film.id),
                    onDelete: () =>
                        ref.read(filmsProvider.notifier).supprimer(film.id),
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

// ── Widget section API (tendances / résultats) ───────────────────────────────

class _ApiSection extends ConsumerWidget {
  const _ApiSection({
    required this.isSearching,
    required this.apiQuery,
    required this.onAjouter,
  });

  final bool isSearching;
  final String apiQuery;
  final void Function(Film film) onAjouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (isSearching) {
      // ── Résultats de recherche ──────────────────────────────────
      final results = ref.watch(filmSearchResultsProvider);
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                'Résultats TMDB pour "$apiQuery"',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            results.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: _ErrorTile(message: e.toString()),
              ),
              data: (items) => items.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.search_off,
                        titre: 'Aucun résultat TMDB',
                      ),
                    )
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
                            annee: r.annee,
                            imageUrl: r.imageUrl,
                            typeIcon: Icons.movie_outlined,
                            onAjouter: () => onAjouter(r.toFilm()),
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

    // ── Tendances TMDB ──────────────────────────────────────────
    final trending = ref.watch(trendingFilmsProvider);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Text(
              'Tendances actuelles',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: trending.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorTile(message: e.toString()),
                data: (items) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final r = items[i];
                    return SizedBox(
                      width: 150,
                      child: ApiResultCard(
                        titre: r.titre,
                        annee: r.annee,
                        imageUrl: r.imageUrl,
                        typeIcon: Icons.movie_outlined,
                        onAjouter: () => onAjouter(r.toFilm()),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(Icons.wifi_off_outlined,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Impossible de charger les données. Vérifie ta connexion.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
}
