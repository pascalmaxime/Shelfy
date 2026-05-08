import '../../domain/entities/media_item.dart';

class GoogleBookResult {
  final String id;
  final String titre;
  final String? auteur;
  final int? annee;
  final String? imageUrl;
  final String? description;
  final String? genreRaw; // Catégorie brute renvoyée par l'API (en anglais)

  const GoogleBookResult({
    required this.id,
    required this.titre,
    this.auteur,
    this.annee,
    this.imageUrl,
    this.description,
    this.genreRaw,
  });

  /// Mapping des catégories Google Books (en anglais) → genres français de l'app.
  static const _genreMap = <String, String>{
    'fiction': 'Roman',
    'literary fiction': 'Roman',
    'literary collections': 'Roman',
    'general fiction': 'Roman',
    'historical fiction': 'Roman',
    'mystery & detective': 'Policier',
    'mystery': 'Policier',
    'detective': 'Policier',
    'crime': 'Policier',
    'suspense': 'Thriller',
    'thrillers': 'Thriller',
    'thriller': 'Thriller',
    'psychological fiction': 'Thriller',
    'science fiction': 'Science-Fiction',
    'science-fiction': 'Science-Fiction',
    'fantasy': 'Fantasy',
    'epic fantasy': 'Fantasy',
    'biography & autobiography': 'Biographie',
    'biography': 'Biographie',
    'autobiography': 'Biographie',
    'memoirs': 'Biographie',
    'history': 'Histoire',
    'historical': 'Histoire',
    'self-help': 'Développement personnel',
    'personal development': 'Développement personnel',
    'business & economics': 'Développement personnel',
    'comics & graphic novels': 'BD / Manga',
    'comics': 'BD / Manga',
    'manga': 'BD / Manga',
    'graphic novels': 'BD / Manga',
    'poetry': 'Poésie',
    'juvenile fiction': 'Jeunesse',
    'juvenile nonfiction': 'Jeunesse',
    "children's": 'Jeunesse',
    'young adult': 'Jeunesse',
    'literary criticism': 'Essai',
    'philosophy': 'Essai',
    'essays': 'Essai',
    'social science': 'Essai',
  };

  /// Retourne le genre français correspondant à la catégorie API.
  String? get genreFr {
    if (genreRaw == null) return null;
    final key = genreRaw!.toLowerCase().trim();
    if (_genreMap.containsKey(key)) return _genreMap[key];
    // Correspondance partielle (ex: "Fiction / Mystery & Detective" → 'Policier')
    for (final entry in _genreMap.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return null;
  }

  factory GoogleBookResult.fromJson(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final authors = info['authors'] as List<dynamic>?;
    final dateStr = info['publishedDate'] as String?;
    final annee = (dateStr != null && dateStr.length >= 4)
        ? int.tryParse(dateStr.substring(0, 4))
        : null;
    final images = info['imageLinks'] as Map<String, dynamic>?;
    String? imageUrl =
        (images?['thumbnail'] ?? images?['smallThumbnail']) as String?;
    // Forcer HTTPS
    if (imageUrl != null) imageUrl = imageUrl.replaceFirst('http://', 'https://');
    final categories = info['categories'] as List<dynamic>?;

    return GoogleBookResult(
      id: json['id'] as String? ?? '',
      titre: info['title'] as String? ?? '',
      auteur: authors != null && authors.isNotEmpty
          ? authors.first as String
          : null,
      annee: annee,
      imageUrl: imageUrl,
      description: info['description'] as String?,
      genreRaw: categories != null && categories.isNotEmpty
          ? categories.first as String
          : null,
    );
  }

  /// Convertit en Livre prêt à ajouter à la collection.
  Livre toLivre() => Livre(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titre: titre,
        auteur: auteur,
        annee: annee,
        genre: genreFr,
        description: description,
        imageUrl: imageUrl,
        statut: StatutLivre.aLire,
      );
}
