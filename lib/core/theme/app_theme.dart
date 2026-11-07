import 'package:flutter/material.dart';

/// Identité visuelle REVATZ : bleu sombre, doré, blanc.
class AppColors {
  static const navy = Color(0xFF0B1F4B);
  static const navyLight = Color(0xFF16336E);
  static const navyDeep = Color(0xFF071533);
  static const gold = Color(0xFFD4AF37);
  static const goldDark = Color(0xFF9A7B1C);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.navy,
      onPrimary: AppColors.white,
      secondary: AppColors.goldDark,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.gold,
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.gold,
      onTertiary: AppColors.navy,
      surface: AppColors.white,
      onSurface: AppColors.navyDeep,
      surfaceContainerLow: const Color(0xFFF3F5FA),
      surfaceContainerHighest: const Color(0xFFE6EBF5),
      outline: const Color(0xFF6B7BA0),
    );
    return _build(scheme, dark: false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.gold,
      onPrimary: AppColors.navy,
      secondary: AppColors.gold,
      onSecondary: AppColors.navy,
      secondaryContainer: AppColors.gold,
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.gold,
      onTertiary: AppColors.navy,
      surface: AppColors.navyDeep,
      onSurface: AppColors.white,
      surfaceContainerLow: const Color(0xFF0E2352),
      surfaceContainerHighest: const Color(0xFF1B3475),
      outline: const Color(0xFF9FB0D6),
    );
    return _build(scheme, dark: true);
  }

  static ThemeData _build(ColorScheme scheme, {required bool dark}) {
    final navBarBg = dark ? AppColors.navy : AppColors.white;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
        actionsIconTheme: IconThemeData(color: AppColors.gold),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBarBg,
        indicatorColor: AppColors.gold,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.navy
                : (dark ? Colors.white70 : AppColors.navyLight),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: dark
                ? (selected ? AppColors.gold : Colors.white70)
                : AppColors.navy,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.gold,
        checkmarkColor: AppColors.navy,
        side: BorderSide(color: scheme.outline.withAlpha(90)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: TextStyle(color: AppColors.white),
        actionTextColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: dark ? AppColors.gold : AppColors.navy,
            width: 2,
          ),
        ),
      ),
      dividerColor: scheme.outline.withAlpha(60),
    );
  }
}
