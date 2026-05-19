part of 'media_item.dart';

enum StatutVinyle { souhaite, possede }

extension StatutVinyleLabel on StatutVinyle {
  String get label => switch (this) {
        StatutVinyle.souhaite => 'Souhaité',
        StatutVinyle.possede => 'Possédé ✓',
      };
}

/// Comment le vinyle a été obtenu.
enum ModeAcquisition { achete, cadeau }

extension ModeAcquisitionLabel on ModeAcquisition {
  String get label => switch (this) {
        ModeAcquisition.achete => 'Acheté',
        ModeAcquisition.cadeau => 'Cadeau',
      };
}

@immutable
final class Vinyle extends MediaItem {
  @override
  final String id;
  @override
  final String titre;
  @override
  final String? imageUrl; // URL pochette
  @override
  final bool enSouhaits;

  final String? artiste;
  final int? annee;
  final String? genre;
  final String? description; // Notes de l'artiste, infos sur l'album
  final StatutVinyle statut;
  final double? note; // 0.5 – 5.0, null = non noté

  /// ID de la release Discogs (pour récupérer le prix marché).
  final int? discogsId;

  /// Prix payé lors de l'acquisition (en euros).
  final double? prixAchat;

  /// Mode d'acquisition : acheté ou cadeau.
  final ModeAcquisition? modeAcquisition;

  const Vinyle({
    required this.id,
    required this.titre,
    this.artiste,
    this.annee,
    this.genre,
    this.description,
    this.imageUrl,
    this.statut = StatutVinyle.souhaite,
    this.enSouhaits = false,
    this.note,
    this.discogsId,
    this.prixAchat,
    this.modeAcquisition,
  });

  Vinyle copyWith({
    String? titre,
    String? artiste,
    int? annee,
    String? genre,
    String? description,
    String? imageUrl,
    StatutVinyle? statut,
    bool? enSouhaits,
    double? note,
    bool clearNote = false,
    int? discogsId,
    double? prixAchat,
    bool clearPrixAchat = false,
    ModeAcquisition? modeAcquisition,
    bool clearModeAcquisition = false,
  }) =>
      Vinyle(
        id: id,
        titre: titre ?? this.titre,
        artiste: artiste ?? this.artiste,
        annee: annee ?? this.annee,
        genre: genre ?? this.genre,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        statut: statut ?? this.statut,
        enSouhaits: enSouhaits ?? this.enSouhaits,
        note: clearNote ? null : (note ?? this.note),
        discogsId: discogsId ?? this.discogsId,
        prixAchat: clearPrixAchat ? null : (prixAchat ?? this.prixAchat),
        modeAcquisition: clearModeAcquisition
            ? null
            : (modeAcquisition ?? this.modeAcquisition),
      );
}
