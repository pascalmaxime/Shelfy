import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_keys.dart';
import '../models/discogs_result.dart';

class DiscogsService {
  static const _base = 'https://api.discogs.com/database/search';

  static Uri _url(Map<String, String> params) =>
      Uri.parse(_base).replace(queryParameters: {
        'token': ApiKeys.discogs,
        'per_page': '20',
        ...params,
      });

  // Headers requis par l'API Discogs
  static const _headers = {
    'User-Agent': 'Shelfy/1.0',
    'Authorization': 'Discogs token=${ApiKeys.discogs}',
  };

  /// Vinyles populaires (triés par nombre de personnes qui les possèdent).
  Future<List<DiscogsResult>> fetchPopular() async {
    final res = await http
        .get(
          _url({'type': 'release', 'sort': 'have', 'sort_order': 'desc'}),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Discogs popular: ${res.statusCode}');
    }
    return _parse(res.body);
  }

  /// Recherche de vinyles par titre / artiste.
  Future<List<DiscogsResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await http
        .get(
          _url({'q': query, 'type': 'release'}),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Discogs search: ${res.statusCode}');
    }
    return _parse(res.body);
  }

  List<DiscogsResult> _parse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => DiscogsResult.fromJson(e as Map<String, dynamic>))
        .where((v) => v.titre.isNotEmpty)
        .toList();
  }
}
