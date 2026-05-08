import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../../features/livres/livres_provider.dart';
import '../shared/image_picker_section.dart';

class AddLivreSheet extends ConsumerStatefulWidget {
  const AddLivreSheet({super.key, this.initial});

  /// Livre pré-rempli depuis un résultat API (optionnel).
  final Livre? initial;

  @override
  ConsumerState<AddLivreSheet> createState() => _AddLivreSheetState();
}

class _AddLivreSheetState extends ConsumerState<AddLivreSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titreCtrl = TextEditingController(text: widget.initial?.titre);
  late final _auteurCtrl =
      TextEditingController(text: widget.initial?.auteur);
  late final _anneeCtrl =
      TextEditingController(text: widget.initial?.annee?.toString());
  String? _imageUrl;
  String? _genre;
  StatutLivre _statut = StatutLivre.aLire;
  bool _enSouhaits = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initial?.imageUrl;
    // Pré-sélectionne le genre de l'API si celui-ci est dans notre liste
    final g = widget.initial?.genre;
    if (g != null && _genres.contains(g)) _genre = g;
  }

  static const _genres = [
    'Roman',
    'Policier',
    'Thriller',
    'Science-Fiction',
    'Fantasy',
    'Biographie',
    'Histoire',
    'Développement personnel',
    'BD / Manga',
    'Essai',
    'Poésie',
    'Jeunesse',
    'Autre',
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _auteurCtrl.dispose();
    _anneeCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(livresProvider.notifier).ajouter(
          Livre(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            titre: _titreCtrl.text.trim(),
            auteur: _auteurCtrl.text.trim().isEmpty
                ? null
                : _auteurCtrl.text.trim(),
            annee: int.tryParse(_anneeCtrl.text.trim()),
            genre: _genre,
            imageUrl: _imageUrl,
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
            Text('Ajouter un livre', style: theme.textTheme.titleLarge),
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

            // Auteur
            TextFormField(
              controller: _auteurCtrl,
              decoration: const InputDecoration(
                labelText: 'Auteur',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // Année
            TextFormField(
              controller: _anneeCtrl,
              decoration: const InputDecoration(
                labelText: 'Année',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final year = int.tryParse(v);
                if (year == null || year < 1 || year > 2100) return 'Invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Photo
            ImagePickerSection(
              imageUrlInitiale: _imageUrl,
              onImageChanged: (url) => setState(() => _imageUrl = url),
            ),
            const SizedBox(height: 12),

            // Genre
            DropdownButtonFormField<String>(
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
            const SizedBox(height: 20),

            // Statut
            Text('Statut', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<StatutLivre>(
              segments: const [
                ButtonSegment(
                  value: StatutLivre.aLire,
                  label: Text('À lire'),
                  icon: Icon(Icons.bookmark_outline),
                ),
                ButtonSegment(
                  value: StatutLivre.lu,
                  label: Text('Lu'),
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
              label: const Text('Ajouter le livre'),
            ),
          ],
        ),
      ),
    );
  }
}
