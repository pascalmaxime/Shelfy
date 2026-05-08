import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/local/local_cache.dart';
import '../../domain/entities/media_item.dart';

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super([]);

  static SupabaseClient get _db => Supabase.instance.client;

  // ── JSON ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toJson(Film f) => {
        'id': f.id,
        'user_id': _db.auth.currentUser!.id,
        'titre': f.titre,
        'realisateur': f.realisateur,
        'annee': f.annee,
        'genre': f.genre,
        'description': f.description,
        'image_url': f.imageUrl,
        'statut': f.statut.name,
        'en_souhaits': f.enSouhaits,
        'note': f.note,
      };

  static Film _fromJson(Map<String, dynamic> j) => Film(
        id: j['id'] as String,
        titre: j['titre'] as String,
        realisateur: j['realisateur'] as String?,
        annee: j['annee'] as int?,
        genre: j['genre'] as String?,
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        statut: StatutFilm.values.firstWhere(
          (e) => e.name == j['statut'],
          orElse: () => StatutFilm.aVoir,
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
      final data = await _db.from('films').select().order('created_at');
      final rows = (data as List).cast<Map<String, dynamic>>();
      state = rows.map(_fromJson).toList();
      await LocalCache.sauvegarder('films_$userId', rows);
    } catch (_) {
      final cached = await LocalCache.charger('films_$userId');
      if (cached != null) state = cached.map(_fromJson).toList();
    }
  }

  void vider() => state = [];

  // ── Mutations ─────────────────────────────────────────────────────────────

  void ajouter(Film film) {
    state = [...state, film];
    _sync(() => _db.from('films').insert(_toJson(film)));
  }

  void supprimer(String id) {
    state = state.where((f) => f.id != id).toList();
    _sync(() => _db.from('films').delete().eq('id', id));
  }

  void toggleStatut(String id) {
    final film = state.firstWhere((f) => f.id == id);
    final nouveau =
        film.statut == StatutFilm.vu ? StatutFilm.aVoir : StatutFilm.vu;
    state = [
      for (final f in state)
        if (f.id == id) f.copyWith(statut: nouveau) else f
    ];
    _sync(() => _db.from('films').update({'statut': nouveau.name}).eq('id', id));
  }

  void toggleSouhaits(String id) {
    final film = state.firstWhere((f) => f.id == id);
    final nouveau = !film.enSouhaits;
    state = [
      for (final f in state)
        if (f.id == id) f.copyWith(enSouhaits: nouveau) else f
    ];
    _sync(() =>
        _db.from('films').update({'en_souhaits': nouveau}).eq('id', id));
  }

  void changerNote(String id, double? note) {
    state = [
      for (final f in state)
        if (f.id == id) f.copyWith(note: note, clearNote: note == null) else f
    ];
    _sync(() => _db.from('films').update({'note': note}).eq('id', id));
  }
}

final filmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (ref) => FilmsNotifier(),
);
