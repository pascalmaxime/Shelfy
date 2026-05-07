import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';

class LivresNotifier extends StateNotifier<List<Livre>> {
  LivresNotifier() : super([]);

  void ajouter(Livre livre) => state = [...state, livre];

  void supprimer(String id) =>
      state = state.where((l) => l.id != id).toList();

  void toggleStatut(String id) => state = [
        for (final l in state)
          if (l.id == id)
            l.copyWith(
              statut: l.statut == StatutLivre.lu ? StatutLivre.aLire : StatutLivre.lu,
            )
          else
            l,
      ];

  void toggleSouhaits(String id) => state = [
        for (final l in state)
          if (l.id == id)
            l.copyWith(enSouhaits: !l.enSouhaits)
          else
            l,
      ];
}

final livresProvider = StateNotifierProvider<LivresNotifier, List<Livre>>(
  (ref) => LivresNotifier(),
);
