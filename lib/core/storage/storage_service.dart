import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Gère l'upload d'images vers Supabase Storage (bucket `shelfy-media`).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ⚠️  ACTION REQUISE dans le Dashboard Supabase :
///   1. Aller dans Storage → Buckets → "New bucket"
///   2. Nom : shelfy-media   |   Public : ✅ activé
///   3. Sauvegarder — c'est tout !
/// ─────────────────────────────────────────────────────────────────────────────
class StorageService {
  static const _bucket = 'shelfy-media';
  static const _uuid = Uuid();

  static SupabaseClient get _db => Supabase.instance.client;

  /// Upload un XFile (résultat de image_picker) et retourne l'URL publique.
  /// Retourne `null` si l'utilisateur n'est pas connecté ou si l'upload échoue.
  static Future<String?> uploadImage(XFile file) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final fileName = '$userId/${_uuid.v4()}.$ext';

      await _db.storage.from(_bucket).uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      return _db.storage.from(_bucket).getPublicUrl(fileName);
    } catch (_) {
      return null;
    }
  }
}
