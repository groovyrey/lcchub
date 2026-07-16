import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5A4BD1);
  static const primaryLight = Color(0xFFA29BFE);
  static const secondary = Color(0xFF00B894);
  static const secondaryDark = Color(0xFF00A381);
  static const background = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1D26);
  static const onSurfaceVariant = Color(0xFF6B7280);
  static const outline = Color(0xFFE5E7EB);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const surfaceVariant = Color(0xFFF0F1F5);
  static const cardBorder = Color(0xFFE8E9EE);

  static const topicAcademics = Color(0xFF6C5CE7);
  static const topicCampusLife = Color(0xFF00B894);
  static const topicCareer = Color(0xFFEF4444);
  static const topicWellBeing = Color(0xFFF59E0B);
  static const topicGeneral = Color(0xFF6B7280);

  static const gradientStart = Color(0xFF6C5CE7);
  static const gradientEnd = Color(0xFFA29BFE);
  static const gradientSecondary = Color(0xFF00B894);
  static const gradientWarm = Color(0xFFF59E0B);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.primaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.12),
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.topicWellBeing,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      error: AppColors.error,
      onError: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: AppColors.outline, thickness: 0.5),
  );
}
