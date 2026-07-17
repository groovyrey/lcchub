import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../services/push_service.dart';
import '../../api/portal_api.dart';
class SettingsScreen extends StatefulWidget {
  final Student? student;
  final bool notificationsEnabled;
  final Function(bool) onNotificationToggle;
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    this.student,
    required this.notificationsEnabled,
    required this.onNotificationToggle,
    required this.themeMode,
    required this.onThemeModeChanged,
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
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
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
                icon: PhosphorIcons.bell(),
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
              _themeSetting(),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _settingItem(
                icon: PhosphorIcons.globeHemisphereWest(),
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
                icon: PhosphorIcons.graduationCap(),
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
              child: Icon(PhosphorIcons.signOut(), color: AppColors.error, size: 20),
            ),
            title: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
            subtitle: Text('Log out of your account', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
            onTap: () => _showLogoutDialog(context),
          ),
        ),
        const SizedBox(height: 16),
        _pushDebugSection(),
      ],
    );
  }

  Widget _themeSetting() {
    final current = widget.themeMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
            child: Icon(
              current == ThemeMode.dark ? PhosphorIcons.moon() : current == ThemeMode.light ? PhosphorIcons.sun() : PhosphorIcons.deviceMobile(),
              size: 20, color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                Text(_themeModeLabel(current), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, icon: Icon(PhosphorIcons.sun(), size: 18)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(PhosphorIcons.deviceMobile(), size: 18)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(PhosphorIcons.moon(), size: 18)),
          ],
            selected: {current},
            onSelectionChanged: (s) => widget.onThemeModeChanged(s.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary.withValues(alpha: 0.15);
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.onSurfaceVariant;
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark:  return 'Dark';
      case ThemeMode.system: return 'Follow system';
    }
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

  Widget _pushDebugSection() {
    final available = PushService.isAvailable;
    final granted = PushService.permissionGranted;
    final token = PushService.deviceToken;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Push Notifications', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _debugRow('Firebase', available ? 'Ready' : 'Not initialized'),
                const SizedBox(height: 6),
                _debugRow('Permission', granted ? 'Granted' : PushService.authorizationStatus == AuthorizationStatus.denied ? 'Denied' : 'Not requested'),
                const SizedBox(height: 6),
                _debugRow('Token', token != null && token.isNotEmpty ? token : '—'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await PushService.refreshToken();
                      final t = PushService.deviceToken;
                      if (t != null && t.isNotEmpty) {
                        await PortalApi.registerDeviceToken(t);
                      }
                      setState(() {});
                    },
                    icon: Icon(PhosphorIcons.arrowClockwise(), size: 16),
                    label: Text('Register / Refresh Token', style: GoogleFonts.poppins(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _debugRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurface)),
        ),
      ],
    );
  }
}
