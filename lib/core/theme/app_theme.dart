import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF3949AB);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );
}
