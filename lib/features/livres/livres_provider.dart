import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/local/local_cache.dart';
import '../../domain/entities/media_item.dart';

class LivresNotifier extends StateNotifier<List<Livre>> {
  LivresNotifier() : super([]);

  static SupabaseClient get _db => Supabase.instance.client;

  // ── JSON ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toJson(Livre l) => {
        'id': l.id,
        'user_id': _db.auth.currentUser!.id,
        'titre': l.titre,
        'auteur': l.auteur,
        'annee': l.annee,
        'genre': l.genre,
        'description': l.description,
        'image_url': l.imageUrl,
        'statut': l.statut.name,
        'en_souhaits': l.enSouhaits,
        'note': l.note,
      };

  static Livre _fromJson(Map<String, dynamic> j) => Livre(
        id: j['id'] as String,
        titre: j['titre'] as String,
        auteur: j['auteur'] as String?,
        annee: j['annee'] as int?,
        genre: j['genre'] as String?,
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        statut: StatutLivre.values.firstWhere(
          (e) => e.name == j['statut'],
          orElse: () => StatutLivre.aLire,
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
      final data = await _db.from('livres').select().order('created_at');
      final rows = (data as List).cast<Map<String, dynamic>>();
      state = rows.map(_fromJson).toList();
      await LocalCache.sauvegarder('livres_$userId', rows);
    } catch (_) {
      final cached = await LocalCache.charger('livres_$userId');
      if (cached != null) state = cached.map(_fromJson).toList();
    }
  }

  void vider() => state = [];

  // ── Mutations ─────────────────────────────────────────────────────────────

  void ajouter(Livre livre) {
    state = [...state, livre];
    _sync(() => _db.from('livres').insert(_toJson(livre)));
  }

  void supprimer(String id) {
    state = state.where((l) => l.id != id).toList();
    _sync(() => _db.from('livres').delete().eq('id', id));
  }

  void toggleStatut(String id) {
    final livre = state.firstWhere((l) => l.id == id);
    final nouveau =
        livre.statut == StatutLivre.lu ? StatutLivre.aLire : StatutLivre.lu;
    state = [
      for (final l in state)
        if (l.id == id) l.copyWith(statut: nouveau) else l
    ];
    _sync(
        () => _db.from('livres').update({'statut': nouveau.name}).eq('id', id));
  }

  void toggleSouhaits(String id) {
    final livre = state.firstWhere((l) => l.id == id);
    final nouveau = !livre.enSouhaits;
    state = [
      for (final l in state)
        if (l.id == id) l.copyWith(enSouhaits: nouveau) else l
    ];
    _sync(() =>
        _db.from('livres').update({'en_souhaits': nouveau}).eq('id', id));
  }

  void changerNote(String id, double? note) {
    state = [
      for (final l in state)
        if (l.id == id) l.copyWith(note: note, clearNote: note == null) else l
    ];
    _sync(() => _db.from('livres').update({'note': note}).eq('id', id));
  }
}

final livresProvider = StateNotifierProvider<LivresNotifier, List<Livre>>(
  (ref) => LivresNotifier(),
);
