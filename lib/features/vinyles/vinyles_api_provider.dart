import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/discogs_result.dart';
import '../../data/remote/discogs_service.dart';
export '../../data/remote/discogs_service.dart' show MarketStats;

final _discogs = DiscogsService();

/// Vinyles populaires (chargés une fois au montage de la page).
final trendingVinylesProvider =
    FutureProvider.autoDispose<List<DiscogsResult>>(
  (ref) => _discogs.fetchPopular(),
);

/// Requête de recherche vinyles.
final vinyleSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Résultats de recherche Discogs.
final vinyleSearchResultsProvider =
    FutureProvider.autoDispose<List<DiscogsResult>>((ref) async {
  final query = ref.watch(vinyleSearchQueryProvider);
  if (query.isEmpty) return [];
  return _discogs.search(query);
});

/// Prix et statistiques de marché Discogs pour un ID de release donné.
/// Mis en cache tant que la page détail est ouverte (autoDispose).
final vinyleMarketStatsProvider =
    FutureProvider.autoDispose.family<MarketStats?, int>(
  (ref, releaseId) => _discogs.fetchMarketStats(releaseId),
);
