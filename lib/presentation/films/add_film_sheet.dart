import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../../features/films/films_provider.dart';

class AddFilmSheet extends ConsumerStatefulWidget {
  const AddFilmSheet({super.key, this.initial});

  /// Film pré-rempli depuis un résultat API (optionnel).
  final Film? initial;

  @override
  ConsumerState<AddFilmSheet> createState() => _AddFilmSheetState();
}

class _AddFilmSheetState extends ConsumerState<AddFilmSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titreCtrl = TextEditingController(text: widget.initial?.titre);
  late final _realisateurCtrl =
      TextEditingController(text: widget.initial?.realisateur);
  late final _anneeCtrl =
      TextEditingController(text: widget.initial?.annee?.toString());
  String? _genre;
  StatutFilm _statut = StatutFilm.aVoir;
  bool _enSouhaits = false;

  static const _genres = [
    'Action',
    'Aventure',
    'Comédie',
    'Drame',
    'Horreur',
    'Thriller',
    'Science-Fiction',
    'Fantasy',
    'Animation',
    'Documentaire',
    'Romance',
    'Biopic',
    'Autre',
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _realisateurCtrl.dispose();
    _anneeCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(filmsProvider.notifier).ajouter(
          Film(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            titre: _titreCtrl.text.trim(),
            realisateur: _realisateurCtrl.text.trim().isEmpty
                ? null
                : _realisateurCtrl.text.trim(),
            annee: int.tryParse(_anneeCtrl.text.trim()),
            genre: _genre,
            statut: _statut,
            enSouhaits: _enSouhaits,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poignée
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Ajouter un film', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Titre
            TextFormField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le titre est requis' : null,
            ),
            const SizedBox(height: 12),

            // Réalisateur
            TextFormField(
              controller: _realisateurCtrl,
              decoration: const InputDecoration(
                labelText: 'Réalisateur',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // Année + Genre
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _anneeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Année',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final year = int.tryParse(v);
                      if (year == null || year < 1888 || year > 2100) {
                        return 'Invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _genre,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      border: OutlineInputBorder(),
                    ),
                    items: _genres
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _genre = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statut
            Text('Statut', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<StatutFilm>(
              segments: const [
                ButtonSegment(
                  value: StatutFilm.aVoir,
                  label: Text('À voir'),
                  icon: Icon(Icons.bookmark_outline),
                ),
                ButtonSegment(
                  value: StatutFilm.vu,
                  label: Text('Vu'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_statut},
              onSelectionChanged: (s) => setState(() => _statut = s.first),
            ),
            const SizedBox(height: 8),

            // Souhaits
            SwitchListTile(
              title: const Text('Ajouter à mes souhaits'),
              subtitle: const Text('Apparaîtra dans ta liste de souhaits'),
              value: _enSouhaits,
              onChanged: (v) => setState(() => _enSouhaits = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _valider,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter le film'),
            ),
          ],
        ),
      ),
    );
  }
}
