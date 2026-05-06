import 'package:flutter/material.dart';

class BibliothequePage extends StatefulWidget {
  const BibliothequePage({super.key});

  @override
  State<BibliothequePage> createState() => _BibliothequePageState();
}

class _BibliothequePageState extends State<BibliothequePage> {
  final Set<String> _selectedTypes = {'Films', 'Livres', 'Vinyles'};
  static const _types = ['Films', 'Livres', 'Vinyles'];

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtrer par type', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final type in _types)
                CheckboxListTile(
                  title: Text(type),
                  value: _selectedTypes.contains(type),
                  onChanged: (checked) {
                    setSheetState(() => setState(() {
                      if (checked == true) {
                        _selectedTypes.add(type);
                      } else {
                        _selectedTypes.remove(type);
                      }
                    }));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = _selectedTypes.length == _types.length;

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Ma bibliothèque'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.list(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher dans ma bibliothèque...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _showFilterSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, size: 18),
                    const SizedBox(width: 8),
                    Text(allSelected ? 'Trier' : 'Trier : ${_selectedTypes.join(', ')}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Ta bibliothèque est vide pour l\'instant.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
