import 'package:flutter/material.dart';
import 'app_text_theme.dart';

class LightColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFFDBEAFE);
  static const secondary = Color(0xFF15803D);
  static const secondaryDark = Color(0xFF166534);
  static const background = Color(0xFFF1F5F9);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF101828);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const outline = Color(0xFFE2E8F0);
  static const cardBorder = Color(0xFFE2E8F0);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFB45309);
  static const success = Color(0xFF15803D);
  static const surfaceVariant = Color(0xFFF8FAFC);
}

class DarkColors {
  static const primary = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF1E3A8A);
  static const secondary = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF10B981);
  static const background = Color(0xFF0B1120);
  static const surface = Color(0xFF111827);
  static const onSurface = Color(0xFFE5E7EB);
  static const onSurfaceVariant = Color(0xFF94A3B8);
  static const outline = Color(0xFF334155);
  static const cardBorder = Color(0xFF334155);
  static const error = Color(0xFFF87171);
  static const warning = Color(0xFFFBBF24);
  static const success = Color(0xFF4ADE80);
  static const surfaceVariant = Color(0xFF1E293B);
}

class AppColors {
  AppColors._();

  static bool _isDark = false;

  static void setThemeBrightness(Brightness brightness) =>
      _isDark = brightness == Brightness.dark;

  static Color get primary => _isDark ? DarkColors.primary : LightColors.primary;
  static Color get primaryDark => _isDark ? DarkColors.primaryDark : LightColors.primaryDark;
  static Color get primaryLight => _isDark ? DarkColors.primaryLight : LightColors.primaryLight;
  static Color get secondary => _isDark ? DarkColors.secondary : LightColors.secondary;
  static Color get secondaryDark => _isDark ? DarkColors.secondaryDark : LightColors.secondaryDark;
  static Color get background => _isDark ? DarkColors.background : LightColors.background;
  static Color get surface => _isDark ? DarkColors.surface : LightColors.surface;
  static Color get onSurface => _isDark ? DarkColors.onSurface : LightColors.onSurface;
  static Color get onSurfaceVariant =>
      _isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;
  static Color get outline => _isDark ? DarkColors.outline : LightColors.outline;
  static Color get cardBorder => _isDark ? DarkColors.cardBorder : LightColors.cardBorder;
  static Color get error => _isDark ? DarkColors.error : LightColors.error;
  static Color get warning => _isDark ? DarkColors.warning : LightColors.warning;
  static Color get success => _isDark ? DarkColors.success : LightColors.success;
  static Color get surfaceVariant =>
      _isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant;

  static const topicAcademics = LightColors.primary;
  static const topicCampusLife = LightColors.success;
  static const topicCareer = LightColors.error;
  static const topicWellBeing = LightColors.warning;
  static const topicGeneral = LightColors.onSurfaceVariant;

  static const gradientStart = LightColors.primary;
  static const gradientEnd = LightColors.primaryDark;
  static const gradientSecondary = LightColors.success;
  static const gradientWarm = LightColors.warning;
}

ThemeData buildAppTheme() => _buildTheme(Brightness.light);

ThemeData buildDarkTheme() => _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colors = isDark ? DarkColors.primary : LightColors.primary;
  final onPrimary = isDark ? DarkColors.background : Colors.white;
  final surface = isDark ? DarkColors.surface : LightColors.surface;
  final onSurface = isDark ? DarkColors.onSurface : LightColors.onSurface;
  final onSurfaceVariant = isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;
  final outline = isDark ? DarkColors.outline : LightColors.outline;
  final surfaceVariant = isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant;
  final primaryLight = isDark ? DarkColors.primaryLight : LightColors.primaryLight;
  final secondary = isDark ? DarkColors.secondary : LightColors.secondary;
  final error = isDark ? DarkColors.error : LightColors.error;
  final warning = isDark ? DarkColors.warning : LightColors.warning;

  final colorScheme = isDark
      ? ColorScheme.dark(
          primary: colors,
          onPrimary: onPrimary,
          primaryContainer: primaryLight,
          onPrimaryContainer: DarkColors.primary,
          secondary: secondary,
          onSecondary: DarkColors.background,
          secondaryContainer: DarkColors.secondaryDark.withValues(alpha: 0.18),
          onSecondaryContainer: DarkColors.secondary,
          tertiary: warning,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          error: error,
          onError: DarkColors.background,
        )
      : ColorScheme.light(
          primary: colors,
          onPrimary: onPrimary,
          primaryContainer: primaryLight,
          onPrimaryContainer: LightColors.primaryDark,
          secondary: secondary,
          onSecondary: Colors.white,
          secondaryContainer: LightColors.success.withValues(alpha: 0.12),
          onSecondaryContainer: LightColors.secondaryDark,
          tertiary: warning,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          error: error,
          onError: Colors.white,
        );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: outline),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? DarkColors.background : LightColors.background,
    textTheme: buildAppTextTheme(isDark ? DarkColors.onSurface : LightColors.onSurface),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: BorderSide(color: colors, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: colors,
      unselectedItemColor: onSurfaceVariant,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    visualDensity: VisualDensity.compact,
  );
}
