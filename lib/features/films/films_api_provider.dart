import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tmdb_result.dart';
import '../../data/remote/tmdb_service.dart';

final _tmdb = TmdbService();

/// Tendances TMDB (chargées une fois au montage de la page).
final trendingFilmsProvider = FutureProvider.autoDispose<List<TmdbResult>>(
  (ref) => _tmdb.fetchTrending(),
);

/// Requête de recherche films (mise à jour par la page via setState + debounce).
final filmSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Résultats de recherche TMDB (réactif à filmSearchQueryProvider).
final filmSearchResultsProvider =
    FutureProvider.autoDispose<List<TmdbResult>>((ref) async {
  final query = ref.watch(filmSearchQueryProvider);
  if (query.isEmpty) return [];
  return _tmdb.search(query);
});
