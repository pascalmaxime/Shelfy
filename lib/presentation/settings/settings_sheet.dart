import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/theme/theme_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final option = ref.watch(themeOptionProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined),
              const SizedBox(width: 12),
              Text('Paramètres', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
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
                ref.read(themeOptionProvider.notifier).state = selected.first,
          ),
        ],
      ),
    );
  }
}
