import 'package:flutter/material.dart';

/// Barre de notation interactive sur 5 étoiles (demi-étoiles supportées).
/// Affiche la valeur /10 sur la droite.
/// Taper sur la moitié gauche d'une étoile = demi-étoile, droite = étoile entière.
/// Taper sur l'étoile déjà sélectionnée efface la note.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.note,
    required this.onChanged,
    this.starSize = 13.0,
  });

  /// Valeur actuelle, 0.5 – 5.0. null = non noté.
  final double? note;

  /// Appelé avec la nouvelle valeur (null pour effacer la note).
  final ValueChanged<double?> onChanged;

  /// Taille de chaque étoile en px.
  final double starSize;

  String get _label {
    if (note == null) return '—/10';
    return '${(note! * 2).toInt()}/10';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final starPadH = starSize * 0.12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...List.generate(5, (i) {
          final threshold = i + 1; // étoile 1 à 5
          final filled = note != null && note! >= threshold;
          final half = note != null && !filled && note! >= threshold - 0.5;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final center = starSize / 2 + starPadH;
              final isHalf = details.localPosition.dx < center;
              final newNote = isHalf ? i + 0.5 : threshold.toDouble();
              onChanged(note == newNote ? null : newNote);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: starPadH),
              child: Icon(
                filled
                    ? Icons.star_rounded
                    : half
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                color: (filled || half)
                    ? Colors.amber.shade600
                    : cs.onSurfaceVariant.withValues(alpha: 0.3),
                size: starSize,
              ),
            ),
          );
        }),
        const SizedBox(width: 5),
        Text(
          _label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: note != null
                ? cs.onSurface
                : cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
