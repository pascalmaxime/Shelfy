import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/app_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('À propos'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo + nom + version ─────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/Logo-Shelfy.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Shelfy',
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Version ${AppInfo.version}',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Section : À propos ───────────────────────────────────────
                _SectionTitre(
                  icon: Icons.info_outline_rounded,
                  label: 'À propos de Shelfy',
                ),
                const SizedBox(height: 12),
                _Carte(
                  child: Text(
                    'Shelfy est une application personnelle conçue pour centraliser '
                    'et organiser ta collection de films, de livres et de vinyles.\n\n'
                    'L\'idée est simple : avoir en un seul endroit tout ce que tu as '
                    'vu, lu ou écouté — ainsi que ce que tu souhaites découvrir. '
                    'Plus besoin de te souvenir si tu as déjà regardé ce film ou '
                    'lu ce roman : ta bibliothèque personnelle est toujours là, '
                    'synchronisée et disponible depuis n\'importe quel appareil.',
                    style: tt.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Section : Comment ça fonctionne ──────────────────────────
                _SectionTitre(
                  icon: Icons.auto_stories_outlined,
                  label: 'Comment ça fonctionne',
                ),
                const SizedBox(height: 12),
                _Carte(
                  child: Column(
                    children: const [
                      _FeatureRow(
                        icon: Icons.search_rounded,
                        titre: 'Recherche intelligente',
                        description:
                            'Shelfy interroge les bases de données TMDB pour les films, '
                            'Google Books pour les livres et Discogs pour les vinyles. '
                            'Les résultats arrivent au fil de ta frappe.',
                      ),
                      _Separateur(),
                      _FeatureRow(
                        icon: Icons.add_circle_outline_rounded,
                        titre: 'Ajout en un tap',
                        description:
                            'Tape sur + depuis les résultats de recherche pour ajouter '
                            'un élément directement à ta collection, sans formulaire.',
                      ),
                      _Separateur(),
                      _FeatureRow(
                        icon: Icons.bookmark_outline_rounded,
                        titre: 'Statuts & organisation',
                        description:
                            'Chaque élément peut avoir un statut : À voir, En cours '
                            'ou Terminé. Ta bibliothèque et ta liste de souhaits se '
                            'mettent à jour automatiquement.',
                      ),
                      _Separateur(),
                      _FeatureRow(
                        icon: Icons.star_outline_rounded,
                        titre: 'Notation',
                        description:
                            'Note tes médias de 0.5 à 5 étoiles (affichées /10). '
                            'Retape la même note pour l\'effacer.',
                      ),
                      _Separateur(),
                      _FeatureRow(
                        icon: Icons.cloud_outlined,
                        titre: 'Synchronisation cloud',
                        description:
                            'Connecte-toi avec ton email pour que ta collection '
                            'soit sauvegardée et retrouvée sur tous tes appareils. '
                            'Un cache local assure la continuité hors connexion.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Section : Contact ────────────────────────────────────────
                _SectionTitre(
                  icon: Icons.mail_outline_rounded,
                  label: 'Nous contacter',
                ),
                const SizedBox(height: 12),
                _Carte(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Une idée d\'amélioration, un bug à signaler ou un retour '
                        'à partager ? Écris-nous directement.',
                        style: tt.bodyMedium?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      _EmailRow(),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Copyright ────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        '© ${AppInfo.anneeCreation} ${AppInfo.proprietaire}',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tous droits réservés.',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shelfy est une application personnelle — toute reproduction '
                        'ou distribution sans autorisation est interdite.',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets internes ────────────────────────────────────────────────────────

class _SectionTitre extends StatelessWidget {
  const _SectionTitre({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.titre,
    required this.description,
  });
  final IconData icon;
  final String titre;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre,
                  style:
                      tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1),
      );
}

class _EmailRow extends StatefulWidget {
  @override
  State<_EmailRow> createState() => _EmailRowState();
}

class _EmailRowState extends State<_EmailRow> {
  bool _copie = false;

  Future<void> _copierEmail() async {
    await Clipboard.setData(
        const ClipboardData(text: AppInfo.emailContact));
    setState(() => _copie = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copie = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppInfo.emailContact,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton.icon(
            onPressed: _copierEmail,
            icon: Icon(
              _copie ? Icons.check_rounded : Icons.copy_outlined,
              size: 16,
            ),
            label: Text(_copie ? 'Copié !' : 'Copier'),
            style: TextButton.styleFrom(
              foregroundColor: _copie ? Colors.green : cs.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
