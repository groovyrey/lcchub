import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/portal_api.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<CommunityPost> _posts = [];
  bool _isLoadingProfile = true;
  bool _isLoadingPosts = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoadingProfile = true; _error = null; });
    final data = await PortalApi.getUserProfile(widget.userId);
    if (!mounted) return;
    if (data != null) {
      setState(() { _profile = data; _isLoadingProfile = false; });
    } else {
      setState(() { _error = 'Could not load profile'; _isLoadingProfile = false; });
    }

    final postsRes = await PortalApi.getCommunityPosts(userId: widget.userId, limit: 50);
    if (!mounted) return;
    setState(() { _posts = postsRes.posts; _isLoadingPosts = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _error != null && _profile == null
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.warningCircle(), size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.poppins(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                TextButton(onPressed: _loadData, child: Text('Retry', style: GoogleFonts.poppins())),
              ],
            ))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                if (_isLoadingProfile)
                  const SliverFillRemaining(child: _ProfileSkeleton())
                else ...[
                  _buildProfileHeader(),
                  _buildBadgesSection(),
                  _buildPostsSection(),
                ],
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: _isLoadingProfile
                ? null
                : _buildAvatar(radius: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({double radius = 40}) {
    final name = _profile?['name'] as String? ?? '?';
    final initials = name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: Text(initials, style: GoogleFonts.poppins(fontSize: radius * 0.8, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildProfileHeader() {
    final p = _profile!;
    final name = p['name'] as String? ?? 'Student';
    final course = p['course'] as String?;
    final yearLevel = p['yearLevel'] as String?;
    final badges = (p['badges'] as List?)?.cast<String>() ?? [];

    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.userId, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant)),
          if (course != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoChip(PhosphorIcons.graduationCap(), course),
                if (yearLevel != null) ...[
                  const SizedBox(width: 8),
                  _infoChip(PhosphorIcons.calendar(), yearLevel),
                ],
              ],
            ),
          ],
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statColumn(PhosphorIcons.article(), '${_posts.length}', 'Posts'),
                Container(width: 1, height: 32, color: AppColors.outline.withValues(alpha: 0.3)),
                _statColumn(PhosphorIcons.trophy(), '${badges.length}', 'Badges'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  static final _badgeMeta = {
    'staff': {'label': 'Staff', 'icon': PhosphorIcons.shield(), 'color': Colors.blue},
    'community_active': {'label': 'Community Active', 'icon': PhosphorIcons.chats(), 'color': Colors.blueGrey},
    'beta_tester': {'label': 'Beta Tester', 'icon': PhosphorIcons.flask(), 'color': Colors.amber},
    'perfect_grade': {'label': 'Perfect Grade', 'icon': PhosphorIcons.trophy(), 'color': Colors.amber},
  };

  Widget _buildBadgesSection() {
    final badges = (_profile?['badges'] as List?)?.cast<String>() ?? [];
    if (badges.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Badges', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((b) {
                final meta = _badgeMeta[b];
                final label = meta?['label'] as String? ?? b;
                final icon = meta?['icon'] as IconData? ?? PhosphorIcons.star();
                final color = (meta?['color'] as Color?) ?? AppColors.primary;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community Posts', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (_isLoadingPosts)
              ...List.generate(2, (_) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ))
            else if (_posts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(PhosphorIcons.chats(), size: 36, color: AppColors.outline.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text('No posts yet', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              )
            else
              ..._posts.map((post) => _postCard(post)),
          ],
        ),
      ),
    );
  }

  Widget _postCard(CommunityPost post) {
    final topicColors = {
      'Academics': Colors.blue,
      'Campus Life': Colors.green,
      'Career': Colors.orange,
      'Well-Being': Colors.purple,
      'General': Colors.blueGrey,
    };
    final topicColor = topicColors[post.topic] ?? AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.topic != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: topicColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(post.topic!, style: GoogleFonts.poppins(fontSize: 11, color: topicColor, fontWeight: FontWeight.w500)),
                  ),
                const Spacer(),
                Text(_formatTime(post.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content, style: GoogleFonts.poppins(fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(PhosphorIcons.heart(), size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Text('${post.likes?.length ?? 0}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(width: 12),
                Icon(PhosphorIcons.chatCircle(), size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Text('${post.commentCount}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = createdAt is String ? DateTime.parse(createdAt).toLocal() : DateTime.now();
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
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(width: 140, height: 18, decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(width: 80, height: 14, decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          ...List.generate(2, (_) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 80,
            decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
          )),
        ],
      ),
    );
  }
}
