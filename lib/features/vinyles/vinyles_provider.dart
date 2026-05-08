import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/local/local_cache.dart';
import '../../domain/entities/media_item.dart';

class VinylesNotifier extends StateNotifier<List<Vinyle>> {
  VinylesNotifier() : super([]);

  static SupabaseClient get _db => Supabase.instance.client;

  // ── JSON ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toJson(Vinyle v) => {
        'id': v.id,
        'user_id': _db.auth.currentUser!.id,
        'titre': v.titre,
        'artiste': v.artiste,
        'annee': v.annee,
        'genre': v.genre,
        'description': v.description,
        'image_url': v.imageUrl,
        'statut': v.statut.name,
        'en_souhaits': v.enSouhaits,
        'note': v.note,
      };

  static Vinyle _fromJson(Map<String, dynamic> j) => Vinyle(
        id: j['id'] as String,
        titre: j['titre'] as String,
        artiste: j['artiste'] as String?,
        annee: j['annee'] as int?,
        genre: j['genre'] as String?,
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        statut: StatutVinyle.values.firstWhere(
          (e) => e.name == j['statut'],
          orElse: () => StatutVinyle.souhaite,
        ),
        enSouhaits: (j['en_souhaits'] as bool?) ?? false,
        note: (j['note'] as num?)?.toDouble(),
      );

  // ── Sync fire-and-forget ──────────────────────────────────────────────────

  void _sync(Future<dynamic> Function() op) {
    if (_db.auth.currentUser == null) return;
    op().catchError((_) {});
  }

  // ── Chargement / vidage ───────────────────────────────────────────────────

  Future<void> charger() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _db.from('vinyles').select().order('created_at');
      final rows = (data as List).cast<Map<String, dynamic>>();
      state = rows.map(_fromJson).toList();
      await LocalCache.sauvegarder('vinyles_$userId', rows);
    } catch (_) {
      final cached = await LocalCache.charger('vinyles_$userId');
      if (cached != null) state = cached.map(_fromJson).toList();
    }
  }

  void vider() => state = [];

  // ── Mutations ─────────────────────────────────────────────────────────────

  void ajouter(Vinyle vinyle) {
    state = [...state, vinyle];
    _sync(() => _db.from('vinyles').insert(_toJson(vinyle)));
  }

  void supprimer(String id) {
    state = state.where((v) => v.id != id).toList();
    _sync(() => _db.from('vinyles').delete().eq('id', id));
  }

  void toggleStatut(String id) {
    final vinyle = state.firstWhere((v) => v.id == id);
    final nouveau = vinyle.statut == StatutVinyle.possede
        ? StatutVinyle.souhaite
        : StatutVinyle.possede;
    state = [
      for (final v in state)
        if (v.id == id) v.copyWith(statut: nouveau) else v
    ];
    _sync(() =>
        _db.from('vinyles').update({'statut': nouveau.name}).eq('id', id));
  }

  void toggleSouhaits(String id) {
    final vinyle = state.firstWhere((v) => v.id == id);
    final nouveau = !vinyle.enSouhaits;
    state = [
      for (final v in state)
        if (v.id == id) v.copyWith(enSouhaits: nouveau) else v
    ];
    _sync(() =>
        _db.from('vinyles').update({'en_souhaits': nouveau}).eq('id', id));
  }

  void changerNote(String id, double? note) {
    state = [
      for (final v in state)
        if (v.id == id) v.copyWith(note: note, clearNote: note == null) else v
    ];
    _sync(() => _db.from('vinyles').update({'note': note}).eq('id', id));
  }
}

final vinylesProvider = StateNotifierProvider<VinylesNotifier, List<Vinyle>>(
  (ref) => VinylesNotifier(),
);
