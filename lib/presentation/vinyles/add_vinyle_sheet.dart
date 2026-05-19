import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../../features/vinyles/vinyles_provider.dart';
import '../shared/image_picker_section.dart';

class AddVinyleSheet extends ConsumerStatefulWidget {
  const AddVinyleSheet({
    super.key,
    this.initial,
    this.existingId,
    this.onSaved,
  });

  /// Vinyle pré-rempli (depuis API Discogs ou depuis la bibliothèque en édition).
  final Vinyle? initial;

  /// Si fourni, on est en mode édition : on modifie le vinyle existant avec cet ID.
  final String? existingId;

  /// Appelé après sauvegarde avec le vinyle créé / modifié.
  final void Function(Vinyle vinyle)? onSaved;

  bool get _isEditing => existingId != null;

  @override
  ConsumerState<AddVinyleSheet> createState() => _AddVinyleSheetState();
}

class _AddVinyleSheetState extends ConsumerState<AddVinyleSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titreCtrl;
  late final TextEditingController _artisteCtrl;
  late final TextEditingController _anneeCtrl;
  late final TextEditingController _prixCtrl;

  String? _imageUrl;
  String? _genre;
  StatutVinyle _statut = StatutVinyle.souhaite;
  bool _enSouhaits = false;
  ModeAcquisition _modeAcquisition = ModeAcquisition.achete;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _titreCtrl = TextEditingController(text: v?.titre ?? '');
    _artisteCtrl = TextEditingController(text: v?.artiste ?? '');
    _anneeCtrl = TextEditingController(text: v?.annee?.toString() ?? '');
    _prixCtrl = TextEditingController(
      text: v?.prixAchat != null ? v!.prixAchat!.toStringAsFixed(2) : '',
    );
    _imageUrl = v?.imageUrl;

    if (v?.statut != null) _statut = v!.statut;
    if (v?.enSouhaits == true) _enSouhaits = true;
    if (v?.modeAcquisition != null) _modeAcquisition = v!.modeAcquisition!;

    // Pré-sélectionne le genre si dans notre liste
    final g = v?.genre;
    if (g != null && _genres.contains(g)) _genre = g;
  }

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
    _prixCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_formKey.currentState!.validate()) return;

    final prixStr = _prixCtrl.text.trim().replaceAll(',', '.');
    final prixAchat = _modeAcquisition == ModeAcquisition.achete &&
            prixStr.isNotEmpty
        ? double.tryParse(prixStr)
        : null;

    final vinyle = Vinyle(
      id: widget.existingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titre: _titreCtrl.text.trim(),
      artiste: _artisteCtrl.text.trim().isEmpty
          ? null
          : _artisteCtrl.text.trim(),
      annee: int.tryParse(_anneeCtrl.text.trim()),
      genre: _genre,
      imageUrl: _imageUrl,
      statut: _statut,
      enSouhaits: _enSouhaits,
      modeAcquisition: _modeAcquisition,
      prixAchat: prixAchat,
      discogsId: widget.initial?.discogsId,
      description: widget.initial?.description,
      note: widget.initial?.note,
    );

    if (widget._isEditing) {
      ref.read(vinylesProvider.notifier).modifier(vinyle);
    } else {
      ref.read(vinylesProvider.notifier).ajouter(vinyle);
    }

    Navigator.of(context).pop();
    widget.onSaved?.call(vinyle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget._isEditing;

    return SingleChildScrollView(
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
            Text(
              isEditing ? 'Modifier le vinyle' : 'Ajouter un vinyle',
              style: theme.textTheme.titleLarge,
            ),
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
                if (year == null || year < 1900 || year > 2100) {
                  return 'Invalide';
                }
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

            // ── Acquisition (toujours visible) ────────────────────────
            ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Acquisition',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ModeAcquisition>(
                      segments: const [
                        ButtonSegment(
                          value: ModeAcquisition.achete,
                          label: Text('Acheté'),
                          icon: Icon(Icons.shopping_bag_outlined),
                        ),
                        ButtonSegment(
                          value: ModeAcquisition.cadeau,
                          label: Text('Cadeau'),
                          icon: Icon(Icons.card_giftcard_outlined),
                        ),
                      ],
                      selected: {_modeAcquisition},
                      onSelectionChanged: (s) =>
                          setState(() => _modeAcquisition = s.first),
                    ),
                    if (_modeAcquisition == ModeAcquisition.achete) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prixCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Prix payé (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.euro_outlined),
                          hintText: '0.00',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (double.tryParse(
                                  v.trim().replaceAll(',', '.')) ==
                              null) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
              icon: Icon(isEditing ? Icons.check : Icons.add),
              label: Text(isEditing ? 'Enregistrer' : 'Ajouter le vinyle'),
            ),
          ],
        ),
      ),
    );
  }
}
