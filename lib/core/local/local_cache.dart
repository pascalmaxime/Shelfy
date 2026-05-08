import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache local basé sur SharedPreferences.
/// Permet de persister les données pour un accès hors-ligne.
class LocalCache {
  static Future<void> sauvegarder(
      String cle, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cle, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>?> charger(String cle) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(cle);
    if (json == null) return null;
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
