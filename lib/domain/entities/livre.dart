part of 'media_item.dart';

enum StatutLivre { aLire, lu }

extension StatutLivreLabel on StatutLivre {
  String get label => switch (this) {
        StatutLivre.aLire => 'À lire',
        StatutLivre.lu => 'Lu ✓',
      };
}

@immutable
final class Livre extends MediaItem {
  @override
  final String id;
  @override
  final String titre;
  @override
  final String? imageUrl; // URL couverture
  @override
  final bool enSouhaits;

  final String? auteur;
  final int? annee;
  final String? genre;
  final String? description; // Résumé du livre
  final StatutLivre statut;
  final double? note; // 0.5 – 5.0, null = non noté

  const Livre({
    required this.id,
    required this.titre,
    this.auteur,
    this.annee,
    this.genre,
    this.description,
    this.imageUrl,
    this.statut = StatutLivre.aLire,
    this.enSouhaits = false,
    this.note,
  });

  Livre copyWith({
    String? titre,
    String? auteur,
    int? annee,
    String? genre,
    String? description,
    String? imageUrl,
    StatutLivre? statut,
    bool? enSouhaits,
    double? note,
    bool clearNote = false,
  }) =>
      Livre(
        id: id,
        titre: titre ?? this.titre,
        auteur: auteur ?? this.auteur,
        annee: annee ?? this.annee,
        genre: genre ?? this.genre,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        statut: statut ?? this.statut,
        enSouhaits: enSouhaits ?? this.enSouhaits,
        note: clearNote ? null : (note ?? this.note),
      );
}
