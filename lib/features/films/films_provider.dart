import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super([]);

  void ajouter(Film film) => state = [...state, film];

  void supprimer(String id) =>
      state = state.where((f) => f.id != id).toList();

  void toggleStatut(String id) => state = [
        for (final f in state)
          if (f.id == id)
            f.copyWith(
              statut: f.statut == StatutFilm.vu ? StatutFilm.aVoir : StatutFilm.vu,
            )
          else
            f,
      ];

  void toggleSouhaits(String id) => state = [
        for (final f in state)
          if (f.id == id)
            f.copyWith(enSouhaits: !f.enSouhaits)
          else
            f,
      ];

  void changerNote(String id, double? note) => state = [
        for (final f in state)
          if (f.id == id)
            f.copyWith(note: note, clearNote: note == null)
          else
            f,
      ];
}

final filmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (ref) => FilmsNotifier(),
);
