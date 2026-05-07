import 'package:flutter/foundation.dart';

part 'film.dart';
part 'livre.dart';
part 'vinyle.dart';

/// Classe scellée commune à Film, Livre et Vinyle.
/// Tous les sous-types sont déclarés dans la même bibliothèque (part of),
/// ce qui permet le pattern matching exhaustif dans les widgets.
@immutable
sealed class MediaItem {
  const MediaItem();

  String get id;
  String get titre;
  String? get imageUrl;
  bool get enSouhaits;
}
