import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_keys.dart';
import '../models/tmdb_result.dart';

class TmdbService {
  static const _base = 'https://api.themoviedb.org/3';
  static const _lang = 'fr-FR';

  static Uri _url(String path, [Map<String, String>? extra]) {
    final params = {
      'api_key': ApiKeys.tmdb,
      'language': _lang,
      ...?extra,
    };
    return Uri.parse('$_base$path').replace(queryParameters: params);
  }

  /// Tendances de la semaine (films + séries).
  Future<List<TmdbResult>> fetchTrending() async {
    final res = await http.get(_url('/trending/movie/week')).timeout(
          const Duration(seconds: 10),
        );
    if (res.statusCode != 200) throw Exception('TMDB trending: ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbResult.fromJson(e as Map<String, dynamic>))
        .where((r) => r.titre.isNotEmpty)
        .toList();
  }

  /// Recherche de films par titre.
  Future<List<TmdbResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await http
        .get(_url('/search/movie', {'query': query}))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('TMDB search: ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => TmdbResult.fromJson(e as Map<String, dynamic>))
        .where((r) => r.titre.isNotEmpty)
        .toList();
  }
}
