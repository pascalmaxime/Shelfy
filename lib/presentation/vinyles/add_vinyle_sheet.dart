import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../../features/vinyles/vinyles_provider.dart';

class AddVinyleSheet extends ConsumerStatefulWidget {
  const AddVinyleSheet({super.key, this.initial});

  /// Vinyle pré-rempli depuis un résultat API (optionnel).
  final Vinyle? initial;

  @override
  ConsumerState<AddVinyleSheet> createState() => _AddVinyleSheetState();
}

class _AddVinyleSheetState extends ConsumerState<AddVinyleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titreCtrl = TextEditingController(text: widget.initial?.titre);
  late final _artisteCtrl =
      TextEditingController(text: widget.initial?.artiste);
  late final _anneeCtrl =
      TextEditingController(text: widget.initial?.annee?.toString());
  String? _genre;
  StatutVinyle _statut = StatutVinyle.souhaite;
  bool _enSouhaits = false;

  static const _genres = [
    'Rock',
    'Jazz',
    'Blues',
    'Hip-Hop',
    'Électronique',
    'Pop',
    'Classique',
    'Soul / R&B',
    'Folk',
    'Métal',
    'Reggae',
    'Funk',
    'Autre',
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _artisteCtrl.dispose();
    _anneeCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(vinylesProvider.notifier).ajouter(
          Vinyle(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            titre: _titreCtrl.text.trim(),
            artiste: _artisteCtrl.text.trim().isEmpty
                ? null
                : _artisteCtrl.text.trim(),
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
            Text('Ajouter un vinyle', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Titre (album)
            TextFormField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Album *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le titre est requis' : null,
            ),
            const SizedBox(height: 12),

            // Artiste
            TextFormField(
              controller: _artisteCtrl,
              decoration: const InputDecoration(
                labelText: 'Artiste / Groupe',
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
                      if (year == null || year < 1900 || year > 2100) {
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
            SegmentedButton<StatutVinyle>(
              segments: const [
                ButtonSegment(
                  value: StatutVinyle.souhaite,
                  label: Text('Souhaité'),
                  icon: Icon(Icons.bookmark_outline),
                ),
                ButtonSegment(
                  value: StatutVinyle.possede,
                  label: Text('Possédé'),
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
              label: const Text('Ajouter le vinyle'),
            ),
          ],
        ),
      ),
    );
  }
}
