import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AuthorAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AuthorAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 16,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final photo = photoUrl;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final fg = foregroundColor ?? AppColors.primary;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
      onForegroundImageError: (_, _) {},
      child: Text(
        initial,
        style: GoogleFonts.poppins(fontSize: radius * 0.8, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}