import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';

class VinylesNotifier extends StateNotifier<List<Vinyle>> {
  VinylesNotifier() : super([]);

  void ajouter(Vinyle vinyle) => state = [...state, vinyle];

  void supprimer(String id) =>
      state = state.where((v) => v.id != id).toList();

  void toggleStatut(String id) => state = [
        for (final v in state)
          if (v.id == id)
            v.copyWith(
              statut: v.statut == StatutVinyle.possede
                  ? StatutVinyle.souhaite
                  : StatutVinyle.possede,
            )
          else
            v,
      ];

  void toggleSouhaits(String id) => state = [
        for (final v in state)
          if (v.id == id)
            v.copyWith(enSouhaits: !v.enSouhaits)
          else
            v,
      ];
}

final vinylesProvider = StateNotifierProvider<VinylesNotifier, List<Vinyle>>(
  (ref) => VinylesNotifier(),
);
