import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../films/films_provider.dart';
import '../livres/livres_provider.dart';
import '../vinyles/vinyles_provider.dart';

/// Fusionne les 3 collections en une seule liste pour la Bibliothèque.
final bibliothequeProvider = Provider<List<MediaItem>>((ref) {
  final films = ref.watch(filmsProvider);
  final livres = ref.watch(livresProvider);
  final vinyles = ref.watch(vinylesProvider);
  return [...films, ...livres, ...vinyles];
});
