import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/google_book_result.dart';

class GoogleBooksService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  static Uri _url(Map<String, String> params) =>
      Uri.parse(_base).replace(queryParameters: params);

  /// Livres populaires / nouveautés.
  /// Ne lance jamais d'exception — retourne une liste vide si l'API échoue
  /// (rate limit sans clé, réseau lent, etc.).
  Future<List<GoogleBookResult>> fetchPopular() async {
    // Essai 1 : bestsellers français
    try {
      final res = await http.get(_url({
        'q': 'bestseller',
        'orderBy': 'relevance',
        'maxResults': '20',
        'printType': 'books',
        'langRestrict': 'fr',
      })).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final results = _parse(res.body);
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}

    // Essai 2 : livres de fiction populaires (sans restriction de langue)
    try {
      final res = await http.get(_url({
        'q': 'subject:fiction',
        'orderBy': 'relevance',
        'maxResults': '20',
        'printType': 'books',
      })).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return _parse(res.body);
    } catch (_) {}

    return [];
  }

  /// Recherche de livres par titre / auteur.
  Future<List<GoogleBookResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await http.get(_url({
      'q': query,
      'maxResults': '20',
      'printType': 'books',
    })).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('GoogleBooks search: ${res.statusCode}');
    }
    return _parse(res.body);
  }

  List<GoogleBookResult> _parse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => GoogleBookResult.fromJson(e as Map<String, dynamic>))
        .where((b) => b.titre.isNotEmpty)
        .toList();
  }
}
