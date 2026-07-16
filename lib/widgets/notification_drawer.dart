import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  int _selectedTab = 0;
  bool _hasRequestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasRequestedLoad) {
      _hasRequestedLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AppState>().loadNotifications();
      });
    }
  }

  List<AppNotification> _filteredNotifs(List<AppNotification> all) {
    if (_selectedTab == 0) return all.where((n) => !n.isRead).toList();
    return all;
  }

  String _timeAgo(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  Color _typeColor(String type) {
    return switch (type) {
      'success' => AppColors.success,
      'warning' => AppColors.warning,
      'error' => AppColors.error,
      _ => AppColors.primary,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'success' => Icons.check_circle_rounded,
      'warning' => Icons.warning_rounded,
      'error' => Icons.error_rounded,
      _ => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allNotifs = state.notifications;
    final filtered = _filteredNotifs(allNotifs);
    final unreadCount = state.unreadCount;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              decoration: const BoxDecoration(color: AppColors.surface),
              child: Row(
                children: [
                  Text('Notifications', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (allNotifs.isNotEmpty) ...[
                    if (_selectedTab == 0 && unreadCount > 0)
                      TextButton(
                        onPressed: () async {
                          final confirm = await _showConfirmDialog('Mark all as read?');
                          if (confirm) state.markAllNotifsRead();
                        },
                        child: Text('Mark all read', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary)),
                      ),
                    TextButton(
                      onPressed: () async {
                        final confirm = await _showConfirmDialog('Clear all notifications?', destructive: true);
                        if (confirm) state.clearAllNotifs();
                      },
                      child: Text('Clear all', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error)),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.surface,
              child: Row(
                children: [
                  _tabButton('Unread', 0, unreadCount),
                  _tabButton('All', 1, null),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.isNotifLoading
                  ? _buildSkeleton()
                  : filtered.isEmpty
                      ? _buildEmpty(_selectedTab == 0 && allNotifs.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _notifCard(filtered[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index, int? count) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: selected ? AppColors.primary : Colors.transparent, width: 2.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              )),
              if (count != null && count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: Text(count > 99 ? '99+' : '$count', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifCard(AppNotification notif) {
    final color = _typeColor(notif.type);
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => context.read<AppState>().deleteNotif(notif.id),
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) context.read<AppState>().markNotifRead(notif.id);
          if (notif.link != null) _showFullNotif(notif);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notif.isRead ? AppColors.outline.withValues(alpha: 0.4) : color.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(_typeIcon(notif.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!notif.isRead)
                          Container(
                            width: 7, height: 7,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        Expanded(
                          child: Text(notif.title, style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: notif.isRead ? AppColors.onSurface : AppColors.primary,
                          )),
                        ),
                        Text(_timeAgo(notif.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.message, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    if (notif.link != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _showFullNotif(notif),
                        child: Text('View Details', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullNotif(AppNotification notif) {
    final color = _typeColor(notif.type);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_typeIcon(notif.type), color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(_timeAgo(notif.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(notif.message, style: GoogleFonts.poppins(fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
            if (notif.link != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    _navigateToLink(notif.link!);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Close', style: GoogleFonts.poppins()),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _navigateToLink(String link) {
    final state = context.read<AppState>();
    if (link.startsWith('/post/')) {
      final postId = link.replaceFirst('/post/', '');
      state.loadPostDetail(postId);
    } else if (link == '/grades') {
      // Could navigate to grades tab - handled by drawer close
    } else if (link == '/accounts') {
      // Could navigate to accounts tab
    }
  }

  Future<bool> _showConfirmDialog(String message, {bool destructive = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm', style: GoogleFonts.poppins(color: destructive ? AppColors.error : AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 12, color: AppColors.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 10, color: AppColors.outline.withValues(alpha: 0.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool hasReadAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hasReadAll ? Icons.notifications_none_rounded : Icons.notifications_off_rounded,
            size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(hasReadAll ? 'All caught up!' : 'No notifications',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(hasReadAll ? 'Check the All tab' : 'You\'re all clear',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
