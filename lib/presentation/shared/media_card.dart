import 'package:flutter/material.dart';
import '../../domain/entities/media_item.dart';
import 'star_rating.dart';

/// Carte d'affichage unifiée pour Film, Livre et Vinyle.
/// Utilise le pattern matching Dart 3 pour extraire les infos selon le type.
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.item,
    this.onToggleStatut,
    this.onToggleSouhaits,
    this.onDelete,
    this.onChangerNote,
  });

  final MediaItem item;
  final VoidCallback? onToggleStatut;
  final VoidCallback? onToggleSouhaits;
  final VoidCallback? onDelete;
  final ValueChanged<double?>? onChangerNote;

  String get _sousTitre => switch (item) {
        Film f => f.realisateur ?? '',
        Livre l => l.auteur ?? '',
        Vinyle v => v.artiste ?? '',
      };

  String get _annee => switch (item) {
        Film f => f.annee?.toString() ?? '',
        Livre l => l.annee?.toString() ?? '',
        Vinyle v => v.annee?.toString() ?? '',
      };

  String get _statutLabel => switch (item) {
        Film f => f.statut.label,
        Livre l => l.statut.label,
        Vinyle v => v.statut.label,
      };

  bool get _estTermine => switch (item) {
        Film f => f.statut == StatutFilm.vu,
        Livre l => l.statut == StatutLivre.lu,
        Vinyle v => v.statut == StatutVinyle.possede,
      };

  String get _typeLabel => switch (item) {
        Film _ => 'Film',
        Livre _ => 'Livre',
        Vinyle _ => 'Vinyle',
      };

  Color _typeColor(ColorScheme cs) => switch (item) {
        Film _ => cs.primaryContainer,
        Livre _ => cs.tertiaryContainer,
        Vinyle _ => cs.secondaryContainer,
      };

  Color _typeTextColor(ColorScheme cs) => switch (item) {
        Film _ => cs.onPrimaryContainer,
        Livre _ => cs.onTertiaryContainer,
        Vinyle _ => cs.onSecondaryContainer,
      };

  IconData get _placeholderIcon => switch (item) {
        Film _ => Icons.movie_outlined,
        Livre _ => Icons.menu_book_outlined,
        Vinyle _ => Icons.album_outlined,
      };

  double? get _note => switch (item) {
        Film f => f.note,
        Livre l => l.note,
        Vinyle v => v.note,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image / Placeholder ──────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _Placeholder(
                      icon: _placeholderIcon,
                      color: cs.surfaceContainerHighest,
                    ),
                  )
                else
                  _Placeholder(
                    icon: _placeholderIcon,
                    color: cs.surfaceContainerHighest,
                  ),

                // Badge type (coin haut-gauche)
                Positioned(
                  top: 6,
                  left: 6,
                  child: _Badge(
                    label: _typeLabel,
                    background: _typeColor(cs),
                    foreground: _typeTextColor(cs),
                  ),
                ),

                // Bouton cœur (coin haut-droit)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Material(
                    color: cs.surface.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onToggleSouhaits,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          item.enSouhaits
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: item.enSouhaits
                              ? Colors.red.shade400
                              : cs.onSurface,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Texte ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
                if (_sousTitre.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _annee.isNotEmpty ? '$_sousTitre · $_annee' : _sousTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ] else if (_annee.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _annee,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                StarRating(
                  note: _note,
                  onChanged: onChangerNote ?? (_) {},
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onToggleStatut,
                        child: _Badge(
                          label: _statutLabel,
                          background: _estTermine
                              ? cs.primaryContainer
                              : cs.surfaceContainerHigh,
                          foreground: _estTermine
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: color,
        child: Center(
          child: Icon(icon, size: 52, color: Colors.grey.shade400),
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
}
