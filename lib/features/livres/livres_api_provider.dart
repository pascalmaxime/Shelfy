import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/google_book_result.dart';
import '../../data/remote/google_books_service.dart';

final _books = GoogleBooksService();

/// Livres populaires (chargés une fois au montage de la page).
final trendingLivresProvider =
    FutureProvider.autoDispose<List<GoogleBookResult>>(
  (ref) => _books.fetchPopular(),
);

/// Requête de recherche livres.
final livreSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Résultats de recherche Google Books.
final livreSearchResultsProvider =
    FutureProvider.autoDispose<List<GoogleBookResult>>((ref) async {
  final query = ref.watch(livreSearchQueryProvider);
  if (query.isEmpty) return [];
  return _books.search(query);
});
