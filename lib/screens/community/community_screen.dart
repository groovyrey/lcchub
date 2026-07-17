import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class CommunityScreen extends StatefulWidget {
  final List<CommunityPost> posts;
  final bool hasMore;
  final bool isLoading;
  final String? selectedTopic;
  final String searchQuery;
  final String? currentUserId;
  final Function(String?) onTopicSelected;
  final Function(String) onSearchChanged;
  final Function(String) onSortChanged;
  final Function(String) onLikePost;
  final Function(String) onPostClick;
  final Function(String, int) onVotePoll;
  final Function(String) onDeletePost;
  final Function(String) onReportPost;
  final Function(String) onAuthorTap;
  final VoidCallback onCreatePost;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;

  const CommunityScreen({
    super.key,
    required this.posts,
    required this.hasMore,
    required this.isLoading,
    this.selectedTopic,
    required this.searchQuery,
    this.currentUserId,
    required this.onTopicSelected,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onLikePost,
    required this.onPostClick,
    required this.onVotePoll,
    required this.onDeletePost,
    required this.onReportPost,
    required this.onAuthorTap,
    required this.onCreatePost,
    required this.onLoadMore,
    required this.onRefresh,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();
  final _topics = ['All', 'Academics', 'Campus Life', 'Career', 'Well-Being', 'General'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(PhosphorIcons.x(), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _topics.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final isSelected = (topic == 'All' && widget.selectedTopic == null) || widget.selectedTopic == topic;
                return FilterChip(
                  label: Text(topic, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : AppColors.onSurface)),
                  selected: isSelected,
                  onSelected: (_) => widget.onTopicSelected(topic == 'All' ? null : topic),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              child: widget.posts.isEmpty && !widget.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.chats(), size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('No posts found', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: widget.posts.length + (widget.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.posts.length) {
                        widget.onLoadMore();
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      return _postCard(widget.posts[index]);
                    },
                  ),
            ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onCreatePost,
        backgroundColor: AppColors.primary,
        child: Icon(PhosphorIcons.plus(), color: Colors.white),
      ),
    );
  }

  Widget _postCard(CommunityPost post) {
    final displayName = post.isAnonymous ? 'Anonymous' : post.userName;
    final topicColor = _topicColor(post.topic);
    final isLiked = post.likes?.contains(widget.currentUserId) == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () => _showPostActions(post),
        child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onPostClick(post.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: post.isAnonymous ? null : () => widget.onAuthorTap(post.userId),
                          child: Text(displayName, style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: post.isAnonymous ? AppColors.onSurface : AppColors.primary,
                          )),
                        ),
                        Text(_formatTime(post.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (post.topic != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: topicColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(post.topic!, style: GoogleFonts.poppins(fontSize: 11, color: topicColor, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content, style: GoogleFonts.poppins(fontSize: 14), maxLines: 4, overflow: TextOverflow.ellipsis),
              if (post.poll != null) ...[
                const SizedBox(height: 12),
                _pollWidget(post),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.onLikePost(post.id),
                    child: Row(
                      children: [
                        Icon(isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(), size: 16, color: isLiked ? AppColors.error : AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${post.likes?.length ?? 0}', style: GoogleFonts.poppins(fontSize: 12, color: isLiked ? AppColors.error : AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(PhosphorIcons.chatCircle(), size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _pollWidget(CommunityPost post) {
    final poll = post.poll!;
    final totalVotes = poll.totalVotes;
    final hasVoted = poll.options.any((o) => o.votes.contains(widget.currentUserId));

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poll.question, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...List.generate(poll.options.length, (i) {
              final option = poll.options[i];
              final percentage = totalVotes > 0 ? (option.votes.length / totalVotes * 100).round() : 0;
              final isSelected = option.votes.contains(widget.currentUserId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: hasVoted ? null : () => widget.onVotePoll(post.id, i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (hasVoted)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (isSelected ? AppColors.primary : AppColors.onSurfaceVariant).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                                ),
                              ),
                            ),
                            if (hasVoted)
                              Text('$percentage%', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            Text('${totalVotes} vote${totalVotes == 1 ? '' : 's'}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Color _topicColor(String? topic) {
    return switch (topic?.toLowerCase()) {
      'academics' => AppColors.topicAcademics,
      'campus life' => AppColors.topicCampusLife,
      'career' => AppColors.topicCareer,
      'well-being' => AppColors.topicWellBeing,
      _ => AppColors.topicGeneral,
    };
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

  void _showPostActions(CommunityPost post) {
    final isOwner = post.userId == widget.currentUserId;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4, margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(color: AppColors.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
            if (isOwner) ListTile(
              leading: Icon(PhosphorIcons.trash(), color: AppColors.error),
              title: Text('Delete Post', style: GoogleFonts.poppins(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text('Delete Post?', style: GoogleFonts.poppins()),
                    content: Text('This action cannot be undone.', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text('Cancel', style: GoogleFonts.poppins())),
                      TextButton(onPressed: () => Navigator.pop(d, true), child: Text('Delete', style: GoogleFonts.poppins(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.onDeletePost(post.id);
                }
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.flag(), color: AppColors.onSurfaceVariant),
              title: Text('Report Post', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text('Report Post?', style: GoogleFonts.poppins()),
                    content: Text('This post will be reviewed by Aegis AI moderator.', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text('Cancel', style: GoogleFonts.poppins())),
                      TextButton(onPressed: () => Navigator.pop(d, true), child: Text('Report', style: GoogleFonts.poppins())),
                    ],
                  ),
                );
                if (confirm == true) {
                  final reason = await widget.onReportPost(post.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(reason != null ? 'Post removed by Aegis: $reason' : 'Post reported and approved by Aegis'),
                      backgroundColor: reason != null ? AppColors.error : AppColors.primary,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
