import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_item.dart';
import '../../features/films/films_provider.dart';
import '../../features/livres/livres_provider.dart';
import '../../features/vinyles/vinyles_provider.dart';
import '../shared/star_rating.dart';

class DetailPage extends ConsumerStatefulWidget {
  const DetailPage({super.key, required this.itemInitial});
  final MediaItem itemInitial;

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  // ── Item réactif depuis le provider ──────────────────────────────────────

  MediaItem get _item {
    final init = widget.itemInitial;
    return switch (init) {
      Film f => ref.watch(filmsProvider.select(
          (list) => list.firstWhere((x) => x.id == f.id, orElse: () => f))),
      Livre l => ref.watch(livresProvider.select(
          (list) => list.firstWhere((x) => x.id == l.id, orElse: () => l))),
      Vinyle v => ref.watch(vinylesProvider.select(
          (list) => list.firstWhere((x) => x.id == v.id, orElse: () => v))),
    };
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _toggleStatut() {
    switch (_item) {
      case Film f:
        ref.read(filmsProvider.notifier).toggleStatut(f.id);
      case Livre l:
        ref.read(livresProvider.notifier).toggleStatut(l.id);
      case Vinyle v:
        ref.read(vinylesProvider.notifier).toggleStatut(v.id);
    }
  }

  void _toggleSouhaits() {
    switch (_item) {
      case Film f:
        ref.read(filmsProvider.notifier).toggleSouhaits(f.id);
      case Livre l:
        ref.read(livresProvider.notifier).toggleSouhaits(l.id);
      case Vinyle v:
        ref.read(vinylesProvider.notifier).toggleSouhaits(v.id);
    }
  }

  void _changerNote(double? note) {
    switch (_item) {
      case Film f:
        ref.read(filmsProvider.notifier).changerNote(f.id, note);
      case Livre l:
        ref.read(livresProvider.notifier).changerNote(l.id, note);
      case Vinyle v:
        ref.read(vinylesProvider.notifier).changerNote(v.id, note);
    }
  }

  Future<void> _confirmerSuppression() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text(
            'Supprimer "${_item.titre}" de ta collection ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      switch (_item) {
        case Film f:
          ref.read(filmsProvider.notifier).supprimer(f.id);
        case Livre l:
          ref.read(livresProvider.notifier).supprimer(l.id);
        case Vinyle v:
          ref.read(vinylesProvider.notifier).supprimer(v.id);
      }
      if (mounted) context.pop(); // ← GoRouter (corrige le bug "page blanche")
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _sousTitre => switch (_item) {
        Film f => f.realisateur ?? '',
        Livre l => l.auteur ?? '',
        Vinyle v => v.artiste ?? '',
      };

  String get _sousTitreLabel => switch (_item) {
        Film _ => 'Réalisation',
        Livre _ => 'Auteur',
        Vinyle _ => 'Artiste',
      };

  String? get _description => switch (_item) {
        Film f => f.description,
        Livre l => l.description,
        Vinyle v => v.description,
      };

  String get _typeLabel => switch (_item) {
        Film _ => 'Film',
        Livre _ => 'Livre',
        Vinyle _ => 'Vinyle',
      };

  IconData get _typeIcon => switch (_item) {
        Film _ => Icons.movie_outlined,
        Livre _ => Icons.menu_book_outlined,
        Vinyle _ => Icons.album_outlined,
      };

  String get _statutLabel => switch (_item) {
        Film f => f.statut.label,
        Livre l => l.statut.label,
        Vinyle v => v.statut.label,
      };

  bool get _estTermine => switch (_item) {
        Film f => f.statut == StatutFilm.vu,
        Livre l => l.statut == StatutLivre.lu,
        Vinyle v => v.statut == StatutVinyle.possede,
      };

  int? get _annee => switch (_item) {
        Film f => f.annee,
        Livre l => l.annee,
        Vinyle v => v.annee,
      };

  String? get _genre => switch (_item) {
        Film f => f.genre,
        Livre l => l.genre,
        Vinyle v => v.genre,
      };

  double? get _note => switch (_item) {
        Film f => f.note,
        Livre l => l.note,
        Vinyle v => v.note,
      };

  Color _typeColor(ColorScheme cs) => switch (_item) {
        Film _ => cs.primaryContainer,
        Livre _ => cs.tertiaryContainer,
        Vinyle _ => cs.secondaryContainer,
      };

  Color _typeTextColor(ColorScheme cs) => switch (_item) {
        Film _ => cs.onPrimaryContainer,
        Livre _ => cs.onTertiaryContainer,
        Vinyle _ => cs.onSecondaryContainer,
      };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final item = _item;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Retour',
              onPressed: () => context.pop(),
            ),
            title: Text(item.titre, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                onPressed: _toggleSouhaits,
                icon: Icon(
                  item.enSouhaits ? Icons.favorite : Icons.favorite_border,
                  color: item.enSouhaits ? Colors.red.shade400 : null,
                ),
                tooltip:
                    item.enSouhaits ? 'Retirer des souhaits' : 'Ajouter aux souhaits',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image + infos ─────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster / pochette / couverture
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 130,
                          height: 185,
                          child: item.imageUrl != null &&
                                  item.imageUrl!.isNotEmpty
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, e, st) =>
                                      _Placeholder(icon: _typeIcon, cs: cs),
                                )
                              : _Placeholder(icon: _typeIcon, cs: cs),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Méta-données
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge type
                            _TypeBadge(
                              label: _typeLabel,
                              background: _typeColor(cs),
                              foreground: _typeTextColor(cs),
                            ),
                            const SizedBox(height: 10),

                            // Auteur / Réalisateur / Artiste
                            if (_sousTitre.isNotEmpty) ...[
                              Text(
                                _sousTitreLabel.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _sousTitre,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Année
                            if (_annee != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    _annee.toString(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],

                            // Genre
                            if (_genre != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(_genre!,
                                    style: theme.textTheme.labelSmall),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Statut (cliquable)
                            GestureDetector(
                              onTap: _toggleStatut,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _estTermine
                                      ? cs.primaryContainer
                                      : cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _estTermine
                                          ? Icons.check_circle_outline
                                          : Icons.radio_button_unchecked,
                                      size: 14,
                                      color: _estTermine
                                          ? cs.onPrimaryContainer
                                          : cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _statutLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _estTermine
                                            ? cs.onPrimaryContainer
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Ma note ──────────────────────────────────────────────
                  Text(
                    'MA NOTE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StarRating(
                    note: _note,
                    onChanged: _changerNote,
                    starSize: 28,
                  ),

                  // ── Description / Synopsis ────────────────────────────────
                  if (_description != null &&
                      _description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      switch (_item) {
                        Film _ => 'SYNOPSIS',
                        Livre _ => 'RÉSUMÉ',
                        Vinyle _ => 'À PROPOS',
                      },
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DescriptionText(text: _description!),
                  ],

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Suppression ───────────────────────────────────────────
                  OutlinedButton.icon(
                    onPressed: _confirmerSuppression,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer de ma collection'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: cs.error,
                      side:
                          BorderSide(color: cs.error.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.cs});
  final IconData icon;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: cs.surfaceContainerHighest,
        child: Center(
          child: Icon(icon, size: 48, color: Colors.grey.shade400),
        ),
      );
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(
      {required this.label,
      required this.background,
      required this.foreground});
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, color: foreground, fontWeight: FontWeight.w700),
        ),
      );
}

/// Texte de description avec "Voir plus" si le texte est long.
class _DescriptionText extends StatefulWidget {
  const _DescriptionText({required this.text});
  final String text;

  @override
  State<_DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<_DescriptionText> {
  static const _maxLines = 4;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.6, color: cs.onSurfaceVariant),
          maxLines: _expanded ? null : _maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
        ),
        // Bouton "Voir plus / Voir moins" seulement si le texte est long
        if (widget.text.length > 250) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Voir moins' : 'Voir plus',
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
