import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/storage/storage_service.dart';

/// Section "Photo" intégrée dans les formulaires d'ajout.
/// Affiche une vignette si une image est sélectionnée, sinon un bouton.
/// Gère camera / galerie / fichiers selon la plateforme.
class ImagePickerSection extends StatefulWidget {
  const ImagePickerSection({
    super.key,
    this.imageUrlInitiale,
    required this.onImageChanged,
  });

  /// URL déjà connue (pré-remplie depuis l'API).
  final String? imageUrlInitiale;

  /// Appelé avec la nouvelle URL publique (ou null si supprimée).
  final ValueChanged<String?> onImageChanged;

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  final _picker = ImagePicker();
  String? _currentUrl;
  bool _uploading = false;

  static bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrlInitiale;
  }

  // ── Sélection d'image ─────────────────────────────────────────────────────

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      await _upload(file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'accéder à cette source.')),
        );
      }
    }
  }

  Future<void> _upload(XFile file) async {
    setState(() => _uploading = true);
    final url = await StorageService.uploadImage(file);
    if (!mounted) return;
    setState(() {
      _uploading = false;
      _currentUrl = url;
    });
    widget.onImageChanged(url);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Upload impossible. Connecte-toi ou crée le bucket Supabase.'),
        ),
      );
    }
  }

  void _supprimer() {
    setState(() => _currentUrl = null);
    widget.onImageChanged(null);
  }

  // ── Bottom sheet options ──────────────────────────────────────────────────

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Ajouter une image',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              if (_isMobile) ...[
                // Prendre une photo
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFrom(ImageSource.camera);
                  },
                ),
                // Photothèque
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photothèque'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFrom(ImageSource.gallery);
                  },
                ),
                // Fichiers
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Fichiers'),
                  subtitle: const Text('iCloud Drive et autres'),
                  onTap: () {
                    Navigator.pop(ctx);
                    // Sur iOS, l'utilisateur peut naviguer vers Files
                    // depuis le picker galerie via le bouton "…"
                    _pickFrom(ImageSource.gallery);
                  },
                ),
              ] else ...[
                // Desktop : sélecteur de fichier image
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Choisir une image'),
                  subtitle: const Text('JPEG, PNG, WEBP'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFrom(ImageSource.gallery);
                  },
                ),
              ],

              if (_currentUrl != null) ...[
                const Divider(),
                ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Supprimer l\'image',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _supprimer();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _uploading ? null : _showOptions,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 100,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _currentUrl != null ? cs.primary : cs.outlineVariant,
                width: _currentUrl != null ? 1.5 : 1,
              ),
            ),
            child: _uploading
                ? const Center(child: CircularProgressIndicator())
                : _currentUrl != null
                    ? _ImagePreview(url: _currentUrl!, onTap: _showOptions)
                    : _PlaceholderContent(),
          ),
        ),
      ],
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url, required this.onTap});
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(url, fit: BoxFit.cover,
              errorBuilder: (context, e, st) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 32),
                  )),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 32, color: cs.primary),
        const SizedBox(height: 6),
        Text(
          'Ajouter une image',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: cs.primary),
        ),
      ],
    );
  }
}
