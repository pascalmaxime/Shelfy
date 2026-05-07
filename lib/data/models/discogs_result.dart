import '../../domain/entities/media_item.dart';

class DiscogsResult {
  final int id;
  final String titre;
  final String? artiste;
  final int? annee;
  final String? imageUrl;
  final String? genreRaw; // Genre brut renvoyé par l'API (en anglais)

  const DiscogsResult({
    required this.id,
    required this.titre,
    this.artiste,
    this.annee,
    this.imageUrl,
    this.genreRaw,
  });

  /// Mapping des genres Discogs (en anglais) → genres français de l'app.
  static const _genreMap = <String, String>{
    'rock': 'Rock',
    'jazz': 'Jazz',
    'blues': 'Blues',
    'hip hop': 'Hip-Hop',
    'hip-hop': 'Hip-Hop',
    'rap': 'Hip-Hop',
    'electronic': 'Électronique',
    'electronica': 'Électronique',
    'electro': 'Électronique',
    'techno': 'Électronique',
    'house': 'Électronique',
    'pop': 'Pop',
    'classical': 'Classique',
    'classical music': 'Classique',
    'soul': 'Soul / R&B',
    'r&b': 'Soul / R&B',
    'rhythm & blues': 'Soul / R&B',
    'funk / soul': 'Soul / R&B',
    'funk': 'Funk',
    'folk': 'Folk',
    'folk, world, & country': 'Folk',
    'country': 'Folk',
    'world': 'Folk',
    'metal': 'Métal',
    'heavy metal': 'Métal',
    'hard rock': 'Métal',
    'reggae': 'Reggae',
    'dub': 'Reggae',
    'latin': 'Autre',
    'stage & screen': 'Autre',
    "children's": 'Autre',
    'non-music': 'Autre',
  };

  /// Retourne le genre français correspondant au genre Discogs brut.
  String? get genreFr {
    if (genreRaw == null) return null;
    final key = genreRaw!.toLowerCase().trim();
    if (_genreMap.containsKey(key)) return _genreMap[key];
    for (final entry in _genreMap.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return null;
  }

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
      genreRaw: genres != null && genres.isNotEmpty ? genres.first as String : null,
    );
  }

  /// Convertit en Vinyle prêt à ajouter à la collection.
  Vinyle toVinyle() => Vinyle(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titre: titre,
        artiste: artiste,
        annee: annee,
        imageUrl: imageUrl,
        genre: genreFr, // Genre mappé vers les options du formulaire
        statut: StatutVinyle.souhaite,
      );
}
