import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light theme base values ───────────────────────────────────────
  static const _lPrimary       = Color(0xFF6C5CE7);
  static const _lPrimaryDark   = Color(0xFF5A4BD1);
  static const _lPrimaryLight  = Color(0xFFA29BFE);
  static const _lSecondary     = Color(0xFF00B894);
  static const _lSecondaryDark = Color(0xFF00A381);
  static const _lBackground    = Color(0xFFF5F6FA);
  static const _lSurface       = Color(0xFFFFFFFF);
  static const _lOnSurface     = Color(0xFF1A1D26);
  static const _lOnSurfaceVar  = Color(0xFF6B7280);
  static const _lOutline       = Color(0xFFE5E7EB);
  static const _lError         = Color(0xFFEF4444);
  static const _lWarning       = Color(0xFFF59E0B);
  static const _lSuccess       = Color(0xFF10B981);
  static const _lSurfaceVar    = Color(0xFFF0F1F5);
  static const _lCardBorder    = Color(0xFFE8E9EE);

  // ── Theme-independent (same in both modes) ─────────────────────────
  static const topicAcademics  = Color(0xFF6C5CE7);
  static const topicCampusLife = Color(0xFF00B894);
  static const topicCareer     = Color(0xFFEF4444);
  static const topicWellBeing  = Color(0xFFF59E0B);
  static const topicGeneral    = Color(0xFF6B7280);

  static const gradientStart    = Color(0xFF6C5CE7);
  static const gradientEnd      = Color(0xFFA29BFE);
  static const gradientSecondary = Color(0xFF00B894);
  static const gradientWarm     = Color(0xFFF59E0B);

  // ── Runtime brightness flag ────────────────────────────────────────
  static bool _isDark = false;

  /// Call whenever the resolved brightness changes.
  static void setThemeBrightness(Brightness b) =>
      _isDark = b == Brightness.dark;

  // ── Theme-aware getters ────────────────────────────────────────────
  static Color get primary       => _isDark ? DarkColors.primary       : _lPrimary;
  static Color get primaryDark   => _isDark ? DarkColors.primaryDark   : _lPrimaryDark;
  static Color get primaryLight  => _isDark ? DarkColors.primaryLight  : _lPrimaryLight;
  static Color get secondary     => _isDark ? DarkColors.secondary     : _lSecondary;
  static Color get secondaryDark => _isDark ? DarkColors.secondaryDark : _lSecondaryDark;
  static Color get background    => _isDark ? DarkColors.background    : _lBackground;
  static Color get surface       => _isDark ? DarkColors.surface       : _lSurface;
  static Color get onSurface     => _isDark ? DarkColors.onSurface     : _lOnSurface;
  static Color get onSurfaceVariant => _isDark ? DarkColors.onSurfaceVariant : _lOnSurfaceVar;
  static Color get outline       => _isDark ? DarkColors.outline       : _lOutline;
  static Color get error         => _isDark ? DarkColors.error         : _lError;
  static Color get warning       => _isDark ? DarkColors.warning       : _lWarning;
  static Color get success       => _isDark ? DarkColors.success       : _lSuccess;
  static Color get surfaceVariant => _isDark ? DarkColors.surfaceVariant : _lSurfaceVar;
  static Color get cardBorder    => _isDark ? DarkColors.cardBorder    : _lCardBorder;
}

class DarkColors {
  DarkColors._();

  static const primary       = Color(0xFFA29BFE);
  static const primaryDark   = Color(0xFF6C5CE7);
  static const primaryLight  = Color(0xFFD6CCFF);
  static const secondary     = Color(0xFF00E6B8);
  static const secondaryDark = Color(0xFF00B894);
  static const background    = Color(0xFF0F1117);
  static const surface       = Color(0xFF1A1D2E);
  static const onSurface     = Color(0xFFE8E9EE);
  static const onSurfaceVariant = Color(0xFF9CA3AF);
  static const outline       = Color(0xFF2D3142);
  static const error         = Color(0xFFF87171);
  static const warning       = Color(0xFFFBBF24);
  static const success       = Color(0xFF34D399);
  static const surfaceVariant = Color(0xFF232738);
  static const cardBorder    = Color(0xFF2D3142);
}

// ── Theme builders ──────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors._lPrimary,
      onPrimary: AppColors._lSurface,
      primaryContainer: AppColors._lPrimaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: AppColors._lPrimaryDark,
      secondary: AppColors._lSecondary,
      onSecondary: AppColors._lSurface,
      secondaryContainer: AppColors._lSecondary.withValues(alpha: 0.12),
      onSecondaryContainer: AppColors._lSecondaryDark,
      tertiary: AppColors._lWarning,
      surface: AppColors._lSurface,
      onSurface: AppColors._lOnSurface,
      surfaceContainerHighest: AppColors._lSurfaceVar,
      onSurfaceVariant: AppColors._lOnSurfaceVar,
      outline: AppColors._lOutline,
      error: AppColors._lError,
      onError: AppColors._lSurface,
    ),
    scaffoldBackgroundColor: AppColors._lBackground,
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors._lSurface,
      foregroundColor: AppColors._lOnSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: AppColors._lOutline, thickness: 0.5),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: DarkColors.primary,
      onPrimary: DarkColors.surface,
      primaryContainer: DarkColors.primaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: DarkColors.primary,
      secondary: DarkColors.secondary,
      onSecondary: DarkColors.surface,
      secondaryContainer: DarkColors.secondary.withValues(alpha: 0.12),
      onSecondaryContainer: DarkColors.secondaryDark,
      tertiary: DarkColors.warning,
      surface: DarkColors.surface,
      onSurface: DarkColors.onSurface,
      surfaceContainerHighest: DarkColors.surfaceVariant,
      onSurfaceVariant: DarkColors.onSurfaceVariant,
      outline: DarkColors.outline,
      error: DarkColors.error,
      onError: DarkColors.surface,
    ),
    scaffoldBackgroundColor: DarkColors.background,
    cardTheme: CardThemeData(
      elevation: 0,
      color: DarkColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: DarkColors.outline.withValues(alpha: 0.5)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.onSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: DarkColors.outline, thickness: 0.5),
  );
}
