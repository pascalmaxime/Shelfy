part of 'media_item.dart';

enum StatutFilm { aVoir, vu }

extension StatutFilmLabel on StatutFilm {
  String get label => switch (this) {
        StatutFilm.aVoir => 'À voir',
        StatutFilm.vu => 'Vu ✓',
      };
}

@immutable
final class Film extends MediaItem {
  @override
  final String id;
  @override
  final String titre;
  @override
  final String? imageUrl; // URL affiche
  @override
  final bool enSouhaits;

  final String? realisateur;
  final int? annee;
  final String? genre;
  final StatutFilm statut;
  final double? note; // 0.5 – 5.0, null = non noté

  const Film({
    required this.id,
    required this.titre,
    this.realisateur,
    this.annee,
    this.genre,
    this.imageUrl,
    this.statut = StatutFilm.aVoir,
    this.enSouhaits = false,
    this.note,
  });

  Film copyWith({
    String? titre,
    String? realisateur,
    int? annee,
    String? genre,
    String? imageUrl,
    StatutFilm? statut,
    bool? enSouhaits,
    double? note,
    bool clearNote = false,
  }) =>
      Film(
        id: id,
        titre: titre ?? this.titre,
        realisateur: realisateur ?? this.realisateur,
        annee: annee ?? this.annee,
        genre: genre ?? this.genre,
        imageUrl: imageUrl ?? this.imageUrl,
        statut: statut ?? this.statut,
        enSouhaits: enSouhaits ?? this.enSouhaits,
        note: clearNote ? null : (note ?? this.note),
      );
}
