/// Informations statiques de l'application.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ⬅️  MISE À JOUR DE LA VERSION
///     Ce fichier est la seule source de vérité pour la version affichée
///     dans les Paramètres. Modifie [version] à chaque nouvelle release.
///     Pense à synchroniser avec la ligne `version:` dans pubspec.yaml.
/// ─────────────────────────────────────────────────────────────────────────────
class AppInfo {
  AppInfo._();

  /// Numéro de version affiché dans les Paramètres → "Version 1.0.0"
  /// ⬅️  À modifier manuellement à chaque release
  static const String version = 'Bêta : 1.1.0';

  /// Année de création — mis à jour si besoin dans le copyright
  static const int anneeCreation = 2026;

  /// Propriétaire et créateur de l'application
  static const String proprietaire = 'PASCAL Maxime';

  /// Adresse e-mail pour les retours, bugs et suggestions
  /// ⬅️  Remplace par ton adresse personnelle
  static const String emailContact = 'maxpascalapp@gmail.com';
}
