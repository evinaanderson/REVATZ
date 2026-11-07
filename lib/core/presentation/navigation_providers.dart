import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onglet actif de la barre de navigation (0 = Sermons).
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
