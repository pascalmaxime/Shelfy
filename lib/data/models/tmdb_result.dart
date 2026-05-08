import '../../domain/entities/media_item.dart';

class TmdbResult {
  final int id;
  final String titre;
  final int? annee;
  final String? imageUrl;
  final String? description;
  final List<int> genreIds;

  const TmdbResult({
    required this.id,
    required this.titre,
    this.annee,
    this.imageUrl,
    this.description,
    this.genreIds = const [],
  });

  /// Mapping IDs de genre TMDB → genres français de l'app.
  /// Les IDs TMDB sont fixes (documentés sur developer.themoviedb.org).
  static const _genreMap = <int, String>{
    28: 'Action',
    12: 'Aventure',
    16: 'Animation',
    35: 'Comédie',
    80: 'Thriller',         // Crime
    99: 'Documentaire',
    18: 'Drame',
    10751: 'Autre',         // Family
    14: 'Fantasy',
    36: 'Autre',            // History
    27: 'Horreur',
    10402: 'Autre',         // Music
    9648: 'Thriller',       // Mystery
    10749: 'Romance',
    878: 'Science-Fiction',
    10770: 'Autre',         // TV Movie
    53: 'Thriller',
    10752: 'Autre',         // War
    37: 'Autre',            // Western
  };

  /// Premier genre significatif (hors "Autre") correspondant aux genre_ids TMDB.
  String? get genre {
    for (final id in genreIds) {
      final g = _genreMap[id];
      if (g != null && g != 'Autre') return g;
    }
    for (final id in genreIds) {
      if (_genreMap.containsKey(id)) return 'Autre';
    }
    return null;
  }

  factory TmdbResult.fromJson(Map<String, dynamic> json) {
    final dateStr = (json['release_date'] ?? json['first_air_date']) as String?;
    final annee = (dateStr != null && dateStr.length >= 4)
        ? int.tryParse(dateStr.substring(0, 4))
        : null;
    final posterPath = json['poster_path'] as String?;
    final genreIds = (json['genre_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    return TmdbResult(
      id: json['id'] as int,
      titre: (json['title'] ?? json['name']) as String? ?? '',
      annee: annee,
      imageUrl: posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : null,
      description: json['overview'] as String?,
      genreIds: genreIds,
    );
  }

  /// Convertit en Film prêt à ajouter à la collection.
  /// Le réalisateur est fetché séparément (via TmdbService.fetchDirector)
  /// et passé en paramètre optionnel.
  Film toFilm({String? realisateur}) => Film(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titre: titre,
        realisateur: realisateur,
        annee: annee,
        genre: genre,
        description: description,
        imageUrl: imageUrl,
        statut: StatutFilm.aVoir,
      );
}
