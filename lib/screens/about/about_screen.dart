import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text('LCC Hub', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Student Portal', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _infoCard('About', 'LCC Hub is a student portal application designed for LCCIAN students to access their academic information, view grades, check financial status, and connect with the community.'),
        const SizedBox(height: 12),
        _infoCard('Features', '• View grades and academic records\n• Check financial status and payments\n• Browse community posts\n• AI-powered assistant\n• Daily schedule reminders'),
        const SizedBox(height: 12),
        _infoCard('Version', '1.0.0'),
      ],
    );
  }

  Widget _infoCard(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(content, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
