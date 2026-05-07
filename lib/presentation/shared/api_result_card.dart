import 'package:flutter/material.dart';

/// Carte d'affichage d'un résultat API (TMDB / Google Books / Discogs).
/// Affiche l'image, le titre, le sous-titre, l'année et un bouton "+ Ajouter".
class ApiResultCard extends StatelessWidget {
  const ApiResultCard({
    super.key,
    required this.titre,
    this.sousTitre,
    this.annee,
    this.imageUrl,
    this.typeIcon,
    required this.onAjouter,
    this.isLoading = false,
  });

  final String titre;
  final String? sousTitre;
  final int? annee;
  final String? imageUrl;
  final IconData? typeIcon;
  final VoidCallback onAjouter;

  /// Quand true, remplace le bouton "+" par un spinner (fetch en cours).
  final bool isLoading;

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
          // ── Image ────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, err, st) => _Placeholder(
                      icon: typeIcon ?? Icons.image_not_supported_outlined,
                      color: cs.surfaceContainerHighest,
                    ),
                  )
                else
                  _Placeholder(
                    icon: typeIcon ?? Icons.image_not_supported_outlined,
                    color: cs.surfaceContainerHighest,
                  ),

                // Bouton ajouter (coin bas-droit) — ou spinner si isLoading
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Material(
                    color: isLoading
                        ? cs.surfaceContainerHighest
                        : cs.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onAjouter,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.add,
                                color: cs.onPrimary,
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
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
                if (sousTitre != null && sousTitre!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    annee != null ? '$sousTitre · $annee' : sousTitre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ] else if (annee != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    annee.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
          child: Icon(icon, size: 48, color: Colors.grey.shade400),
        ),
      );
}
