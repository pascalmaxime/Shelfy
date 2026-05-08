import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_item.dart';
import '../../features/vinyles/vinyles_api_provider.dart';
import '../../features/vinyles/vinyles_provider.dart';
import '../shared/api_result_card.dart';
import '../shared/empty_state.dart';
import '../shared/media_card.dart';
import 'add_vinyle_sheet.dart';

class VinylesPage extends ConsumerStatefulWidget {
  const VinylesPage({super.key});

  @override
  ConsumerState<VinylesPage> createState() => _VinylesPageState();
}

class _VinylesPageState extends ConsumerState<VinylesPage> {
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
      ref.read(vinyleSearchQueryProvider.notifier).state = value.trim();
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _localQuery = '');
    ref.read(vinyleSearchQueryProvider.notifier).state = '';
  }

  void _openAddSheet({Vinyle? initial}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddVinyleSheet(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vinyles = ref.watch(vinylesProvider);
    final apiQuery = ref.watch(vinyleSearchQueryProvider);
    final isSearching = apiQuery.isNotEmpty;

    final localFiltered = _localQuery.isEmpty
        ? vinyles
        : vinyles
            .where((v) =>
                v.titre.toLowerCase().contains(_localQuery) ||
                (v.artiste?.toLowerCase().contains(_localQuery) ?? false))
            .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: context.canPop()
              ? BackButton(onPressed: () => context.pop())
              : null,
          title: const Text('Vinyles'),
          actions: [
            IconButton(
              onPressed: () => _openAddSheet(),
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un vinyle',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un vinyle...',
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
          onAjouter: (vinyle) {
            ref.read(vinylesProvider.notifier).ajouter(vinyle);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('"${vinyle.titre}" ajouté à ta collection !'),
              action: SnackBarAction(
                label: 'Voir',
                onPressed: () => context.push('/detail', extra: vinyle),
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
                if (vinyles.isNotEmpty)
                  Text(
                    '${vinyles.length} vinyle${vinyles.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ),

        if (vinyles.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.album_outlined,
              titre: 'Aucun vinyle pour l\'instant',
              sousTitre: 'Appuie sur + pour ajouter ton premier vinyle.',
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
                  final vinyle = localFiltered[i];
                  return MediaCard(
                    item: vinyle,
                    onTap: () => context.push('/detail', extra: vinyle),
                    onToggleStatut: () => ref
                        .read(vinylesProvider.notifier)
                        .toggleStatut(vinyle.id),
                    onToggleSouhaits: () => ref
                        .read(vinylesProvider.notifier)
                        .toggleSouhaits(vinyle.id),
                    onDelete: () =>
                        ref.read(vinylesProvider.notifier).supprimer(vinyle.id),
                    onChangerNote: (note) => ref
                        .read(vinylesProvider.notifier)
                        .changerNote(vinyle.id, note),
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
  final void Function(Vinyle vinyle) onAjouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (isSearching) {
      final results = ref.watch(vinyleSearchResultsProvider);
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Text('Résultats Discogs pour "$apiQuery"',
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
                          titre: 'Aucun résultat Discogs'))
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
                            sousTitre: r.artiste,
                            annee: r.annee,
                            imageUrl: r.imageUrl,
                            typeIcon: Icons.album_outlined,
                            onAjouter: () => onAjouter(r.toVinyle()),
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

    final trending = ref.watch(trendingVinylesProvider);
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
            child: SizedBox(
              height: 220,
              child: trending.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
                        sousTitre: r.artiste,
                        annee: r.annee,
                        imageUrl: r.imageUrl,
                        typeIcon: Icons.album_outlined,
                        onAjouter: () => onAjouter(r.toVinyle()),
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
