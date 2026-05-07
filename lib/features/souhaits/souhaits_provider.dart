import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/media_item.dart';
import '../bibliotheque/bibliotheque_provider.dart';

/// Filtre les items où enSouhaits == true depuis toute la bibliothèque.
final souhaistsProvider = Provider<List<MediaItem>>((ref) {
  return ref
      .watch(bibliothequeProvider)
      .where((item) => item.enSouhaits)
      .toList();
});
