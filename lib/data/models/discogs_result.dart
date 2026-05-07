import '../../domain/entities/media_item.dart';

class DiscogsResult {
  final int id;
  final String titre;
  final String? artiste;
  final int? annee;
  final String? imageUrl;
  final String? genre;

  const DiscogsResult({
    required this.id,
    required this.titre,
    this.artiste,
    this.annee,
    this.imageUrl,
    this.genre,
  });

  factory DiscogsResult.fromJson(Map<String, dynamic> json) {
    // Le titre Discogs est souvent "Artiste - Album", on les sépare
    final rawTitle = json['title'] as String? ?? '';
    String artiste = '';
    String titre = rawTitle;
    if (rawTitle.contains(' - ')) {
      final parts = rawTitle.split(' - ');
      artiste = parts.first.trim();
      titre = parts.sublist(1).join(' - ').trim();
    }

    final yearRaw = json['year'];
    final annee = yearRaw != null ? int.tryParse(yearRaw.toString()) : null;

    final genres = json['genre'] as List<dynamic>?;
    final coverImage = json['cover_image'] as String?;
    // Ignorer les images placeholder de Discogs
    final isPlaceholder = coverImage != null &&
        (coverImage.contains('placeholder') || coverImage.contains('spacer'));

    return DiscogsResult(
      id: json['id'] as int? ?? 0,
      titre: titre,
      artiste: artiste.isNotEmpty ? artiste : null,
      annee: annee,
      imageUrl: (coverImage != null && !isPlaceholder) ? coverImage : null,
      genre: genres != null && genres.isNotEmpty ? genres.first as String : null,
    );
  }

  /// Convertit en Vinyle prêt à ajouter à la collection.
  Vinyle toVinyle() => Vinyle(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titre: titre,
        artiste: artiste,
        annee: annee,
        imageUrl: imageUrl,
        genre: genre,
        statut: StatutVinyle.souhaite,
      );
}
