import '../../domain/entities/media_item.dart';

class GoogleBookResult {
  final String id;
  final String titre;
  final String? auteur;
  final int? annee;
  final String? imageUrl;
  final String? description;
  final String? genre;

  const GoogleBookResult({
    required this.id,
    required this.titre,
    this.auteur,
    this.annee,
    this.imageUrl,
    this.description,
    this.genre,
  });

  factory GoogleBookResult.fromJson(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final authors = info['authors'] as List<dynamic>?;
    final dateStr = info['publishedDate'] as String?;
    final annee = (dateStr != null && dateStr.length >= 4)
        ? int.tryParse(dateStr.substring(0, 4))
        : null;
    final images = info['imageLinks'] as Map<String, dynamic>?;
    String? imageUrl = (images?['thumbnail'] ?? images?['smallThumbnail']) as String?;
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
      genre: categories != null && categories.isNotEmpty
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
        imageUrl: imageUrl,
        statut: StatutLivre.aLire,
      );
}
