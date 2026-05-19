import 'package:flutter/material.dart';

/// Feuille de prévisualisation d'un résultat API avant ajout à la collection.
/// Affiche image, titre, sous-titre (auteur / réalisateur / artiste),
/// année, genre et synopsis.
class ApiPreviewSheet extends StatefulWidget {
  const ApiPreviewSheet({
    super.key,
    required this.titre,
    this.sousTitre,
    this.futureSousTitre,
    this.annee,
    this.genre,
    this.imageUrl,
    this.description,
    this.typeIcon,
    required this.onAjouter,
    this.popAfterAdd = true,
  });

  final String titre;

  /// Sous-titre statique (auteur, artiste…).
  final String? sousTitre;

  /// Sous-titre chargé de manière asynchrone (ex. réalisateur via TMDB credits).
  /// Si fourni, [sousTitre] est ignoré jusqu'à résolution.
  final Future<String?>? futureSousTitre;

  final int? annee;
  final String? genre;
  final String? imageUrl;
  final String? description;
  final IconData? typeIcon;

  /// Appelé quand l'utilisateur tape "Ajouter à ma collection".
  /// Peut être async (ex. fetch director avant d'ajouter).
  final Future<void> Function() onAjouter;

  /// Si false, le sheet ne se ferme PAS automatiquement après [onAjouter].
  /// Utile quand [onAjouter] gère lui-même la navigation (ex. ouvrir un form).
  final bool popAfterAdd;

  @override
  State<ApiPreviewSheet> createState() => _ApiPreviewSheetState();
}

class _ApiPreviewSheetState extends State<ApiPreviewSheet> {
  bool _isAdding = false;
  String? _resolvedSousTitre;
  bool _sousTitreLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.futureSousTitre != null) {
      _sousTitreLoading = true;
      widget.futureSousTitre!.then(
        (v) {
          if (mounted) {
            setState(() {
              _resolvedSousTitre = v;
              _sousTitreLoading = false;
            });
          }
        },
        onError: (_) {
          if (mounted) setState(() => _sousTitreLoading = false);
        },
      );
    }
  }

  Future<void> _handleAjouter() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);
    try {
      await widget.onAjouter();
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
    if (mounted && widget.popAfterAdd) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sousTitre = _resolvedSousTitre ?? widget.sousTitre;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ── Poignée ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header : image + titre / sous-titre / chips ───────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pochette / affiche
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 110,
                  height: 160,
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) => _Placeholder(
                            icon: widget.typeIcon ??
                                Icons.image_not_supported_outlined,
                            color: cs.surfaceContainerHighest,
                          ),
                        )
                      : _Placeholder(
                          icon: widget.typeIcon ??
                              Icons.image_not_supported_outlined,
                          color: cs.surfaceContainerHighest,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Infos texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titre,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    // Sous-titre (auteur / réalisateur / artiste)
                    if (_sousTitreLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Chargement…',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else if (sousTitre != null && sousTitre.isNotEmpty)
                      Text(
                        sousTitre,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),

                    const SizedBox(height: 10),

                    // Chips : année + genre
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (widget.annee != null)
                          _InfoChip(label: widget.annee.toString()),
                        if (widget.genre != null)
                          _InfoChip(label: widget.genre!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Synopsis ───────────────────────────────────────────────
          if (widget.description != null &&
              widget.description!.trim().isNotEmpty) ...[
            Text('Synopsis', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.55,
              ),
              textAlign: TextAlign.justify,
            ),
          ] else
            Text(
              'Aucune description disponible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

          const SizedBox(height: 28),

          // ── Bouton ajouter ─────────────────────────────────────────
          FilledButton.icon(
            onPressed: _isAdding ? null : _handleAjouter,
            icon: _isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(
              _isAdding ? 'Ajout en cours…' : 'Ajouter à ma collection',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSecondaryContainer,
            ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: color,
        child: Center(
          child: Icon(icon, size: 40, color: Colors.grey.shade400),
        ),
      );
}
