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
  final StatutLivre statut;

  const Livre({
    required this.id,
    required this.titre,
    this.auteur,
    this.annee,
    this.genre,
    this.imageUrl,
    this.statut = StatutLivre.aLire,
    this.enSouhaits = false,
  });

  Livre copyWith({
    String? titre,
    String? auteur,
    int? annee,
    String? genre,
    String? imageUrl,
    StatutLivre? statut,
    bool? enSouhaits,
  }) =>
      Livre(
        id: id,
        titre: titre ?? this.titre,
        auteur: auteur ?? this.auteur,
        annee: annee ?? this.annee,
        genre: genre ?? this.genre,
        imageUrl: imageUrl ?? this.imageUrl,
        statut: statut ?? this.statut,
        enSouhaits: enSouhaits ?? this.enSouhaits,
      );
}
