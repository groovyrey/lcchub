import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Student? student;
  final bool notificationsEnabled;
  final Function(bool) onNotificationToggle;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    this.student,
    required this.notificationsEnabled,
    required this.onNotificationToggle,
    required this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notifEnabled;
  bool _publicProfile = true;
  bool _showAcademic = true;

  @override
  void initState() {
    super.initState();
    _notifEnabled = widget.notificationsEnabled;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notificationsEnabled != widget.notificationsEnabled) {
      _notifEnabled = widget.notificationsEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (s != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('ID: ${s.id}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                      if (s.course.isNotEmpty)
                        Text(s.course, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text('Preferences', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _settingItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Enable daily schedule reminders',
                trailing: Switch(
                  value: _notifEnabled,
                  onChanged: (v) {
                    setState(() => _notifEnabled = v);
                    widget.onNotificationToggle(v);
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _settingItem(
                icon: Icons.public,
                title: 'Public Profile',
                subtitle: 'Allow others to see your profile',
                trailing: Switch(
                  value: _publicProfile,
                  onChanged: (v) => setState(() => _publicProfile = v),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _settingItem(
                icon: Icons.school_outlined,
                title: 'Show Academic Info',
                subtitle: 'Display course and year level',
                trailing: Switch(
                  value: _showAcademic,
                  onChanged: (v) => setState(() => _showAcademic = v),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Account', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: AppColors.error, size: 20),
            ),
            title: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
            subtitle: Text('Log out of your account', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
            onTap: () => _showLogoutDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _settingItem({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: Text('Sign Out', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
