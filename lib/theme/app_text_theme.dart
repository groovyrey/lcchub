import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildAppTextTheme(Color color) {
  return Typography.blackMountainView.copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 57, height: 1.1, color: color),
        displayMedium: GoogleFonts.outfit(fontSize: 45, height: 1.1, color: color),
        displaySmall: GoogleFonts.outfit(fontSize: 36, height: 1.2, color: color),
        headlineLarge: GoogleFonts.outfit(fontSize: 32, height: 1.2, color: color),
        headlineMedium: GoogleFonts.outfit(fontSize: 28, height: 1.2, color: color),
        headlineSmall: GoogleFonts.outfit(fontSize: 24, height: 1.3, color: color),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: color),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: color),
        titleSmall: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: color),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: color),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, color: color),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: color),
        labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      );
}
