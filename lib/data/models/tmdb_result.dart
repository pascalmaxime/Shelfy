import '../../domain/entities/media_item.dart';

class TmdbResult {
  final int id;
  final String titre;
  final int? annee;
  final String? imageUrl;
  final String? description;

  const TmdbResult({
    required this.id,
    required this.titre,
    this.annee,
    this.imageUrl,
    this.description,
  });

  factory TmdbResult.fromJson(Map<String, dynamic> json) {
    final dateStr = (json['release_date'] ?? json['first_air_date']) as String?;
    final annee = (dateStr != null && dateStr.length >= 4)
        ? int.tryParse(dateStr.substring(0, 4))
        : null;
    final posterPath = json['poster_path'] as String?;
    return TmdbResult(
      id: json['id'] as int,
      titre: (json['title'] ?? json['name']) as String? ?? '',
      annee: annee,
      imageUrl: posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : null,
      description: json['overview'] as String?,
    );
  }

  /// Convertit en Film prêt à ajouter à la collection.
  Film toFilm() => Film(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titre: titre,
        annee: annee,
        imageUrl: imageUrl,
        statut: StatutFilm.aVoir,
      );
}
