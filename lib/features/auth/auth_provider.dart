import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stream des changements d'état d'authentification Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Utilisateur actuellement connecté, ou null.
final currentUserProvider = Provider<User?>((ref) {
  // Se met à jour à chaque changement d'auth
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentUser;
});
