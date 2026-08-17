import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const emerald = Color(0xFF32D79A);
  static const mint = Color(0xFF8AF2CB);
  static const cyan = Color(0xFF39D7E7);
  static const navy = Color(0xFF07111F);
  static const navySoft = Color(0xFF0E1B2C);
  static const ink = Color(0xFF101828);
  static const cloud = Color(0xFFF4F7FA);
  static const danger = Color(0xFFFF6B7A);
  static const warning = Color(0xFFFFC857);
  static const income = Color(0xFF2ECF8F);
  static const expense = Color(0xFFFF6B7A);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppPalette.navySoft : Colors.white;
    final divider =
        isDark ? Colors.white.withValues(alpha: .08) : const Color(0xFFE8EDF2);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.emerald,
      brightness: brightness,
      primary: AppPalette.emerald,
      secondary: AppPalette.cyan,
      surface: surface,
      error: AppPalette.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppPalette.navy : AppPalette.cloud,
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: isDark ? const Color(0xFFF1F5F9) : AppPalette.ink,
            displayColor: isDark ? Colors.white : AppPalette.ink,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: .08)
                : const Color(0xFFE3E8EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.emerald, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0B1726) : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppPalette.emerald.withValues(alpha: .16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppPalette.emerald
                : (isDark ? const Color(0xFF91A0B0) : const Color(0xFF667085)),
            size: selected ? 24 : 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected
                ? (isDark ? Colors.white : AppPalette.ink)
                : (isDark ? const Color(0xFFA7B4C3) : const Color(0xFF667085)),
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: AppPalette.emerald.withValues(alpha: .16),
        selectedIconTheme: const IconThemeData(color: AppPalette.emerald),
        selectedLabelTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppPalette.ink,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: isDark ? const Color(0xFFA7B4C3) : const Color(0xFF667085),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.emerald,
          foregroundColor: AppPalette.navy,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: .12)
                : const Color(0xFFDDE5EC),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: divider),
        selectedColor: AppPalette.emerald.withValues(alpha: isDark ? .18 : .16),
        backgroundColor: isDark ? const Color(0xFF101E2E) : Colors.white,
        checkmarkColor: AppPalette.emerald,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFFEAF2F8) : AppPalette.ink,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        secondaryLabelStyle: TextStyle(
          color: isDark ? Colors.white : AppPalette.ink,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF172536) : AppPalette.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
