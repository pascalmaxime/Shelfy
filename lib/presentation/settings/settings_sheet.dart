import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_info.dart';
import '../../features/theme/theme_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final option = ref.watch(themeOptionProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.settings_outlined),
              const SizedBox(width: 12),
              Text('Paramètres',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),

          // ── Apparence ─────────────────────────────────────────────────────
          Text(
            'APPARENCE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeOption>(
            segments: const [
              ButtonSegment(
                value: AppThemeOption.light,
                label: Text('Clair'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemeOption.dark,
                label: Text('Sombre'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemeOption.grey,
                label: Text('Gris'),
                icon: Icon(Icons.contrast_outlined),
              ),
            ],
            selected: {option},
            onSelectionChanged: (selected) =>
                ref.read(themeOptionProvider.notifier).set(selected.first),
          ),

          const SizedBox(height: 28),

          // ── Application ───────────────────────────────────────────────────
          Text(
            'APPLICATION',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),

          // Bouton À propos & aide
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Ferme le dialog puis navigue vers la page À propos
              Navigator.of(context).pop();
              context.push('/about');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: cs.primary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À propos & aide',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'But, fonctionnement, contact',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Version (tout en bas) ─────────────────────────────────────────
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${AppInfo.anneeCreation} ${AppInfo.proprietaire}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              Text(
                'Version ${AppInfo.version}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
