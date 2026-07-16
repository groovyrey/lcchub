import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost? post;
  final List<CommunityComment> comments;
  final bool isLoading;
  final String? currentUserId;
  final Function(String) onAddComment;
  final Function(String, int) onVotePoll;
  final Function(String) onLikePost;
  final Function(String) onDeletePost;
  final Function(String) onReportPost;
  final Function(String, String) onDeleteComment;
  final Function(String, String) onReportComment;
  final Function(String) onAuthorTap;

  const PostDetailScreen({
    super.key,
    this.post,
    this.comments = const [],
    this.isLoading = false,
    this.currentUserId,
    required this.onAddComment,
    required this.onVotePoll,
    required this.onLikePost,
    required this.onDeletePost,
    required this.onReportPost,
    required this.onDeleteComment,
    required this.onReportComment,
    required this.onAuthorTap,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLiked = post?.likes?.contains(widget.currentUserId) == true;
    return Scaffold(
      appBar: AppBar(title: Text('Post Detail', style: GoogleFonts.poppins())),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.isLoading || post == null) ...[
                  _skeletonPost(),
                  const SizedBox(height: 24),
                  _skeletonComments(),
                ] else ...[
                  GestureDetector(
                    onLongPress: () => _showPostActions(post),
                    child: _postHeader(post),
                  ),
                  const SizedBox(height: 12),
                  if (post.content.isNotEmpty)
                    Text(post.content, style: GoogleFonts.poppins(fontSize: 14)),
                  if (post.poll != null) ...[
                    const SizedBox(height: 16),
                    _pollWidget(post),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => widget.onLikePost(post.id),
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 18, color: isLiked ? AppColors.error : AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${post.likes?.length ?? 0}', style: GoogleFonts.poppins(fontSize: 13, color: isLiked ? AppColors.error : AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.comment_outlined, size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${widget.comments.length} comments', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Divider(height: 32),
                  ...widget.comments.map((c) => GestureDetector(
                    onLongPress: () => _showCommentActions(c),
                    child: _commentTile(c),
                  )),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outline.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final text = _commentController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onAddComment(text);
                        _commentController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonPost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _skeletonCircle(18),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 120, height: 14),
                const SizedBox(height: 4),
                _skeletonBox(width: 60, height: 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _skeletonBox(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        _skeletonBox(width: 220, height: 14),
        const SizedBox(height: 8),
        _skeletonBox(width: 160, height: 14),
        const SizedBox(height: 16),
        Row(
          children: [
            _skeletonBox(width: 60, height: 16),
            const SizedBox(width: 16),
            _skeletonBox(width: 100, height: 16),
          ],
        ),
      ],
    );
  }

  Widget _skeletonComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonBox(width: 80, height: 14),
        const SizedBox(height: 12),
        ...List.generate(2, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _skeletonCircle(14),
                    const SizedBox(width: 8),
                    _skeletonBox(width: 100, height: 12),
                  ],
                ),
                const SizedBox(height: 8),
                _skeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                _skeletonBox(width: 180, height: 12),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _skeletonCircle(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _skeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _postHeader(CommunityPost post) {
    final displayName = post.isAnonymous ? 'Anonymous' : post.userName;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: post.isAnonymous ? null : () => widget.onAuthorTap(post.userId),
              child: Text(displayName, style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: post.isAnonymous ? AppColors.onSurface : AppColors.primary,
              )),
            ),
            Text(_timeAgo(post.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  String _timeAgo(dynamic createdAt) {
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

  Widget _pollWidget(CommunityPost post) {
    final poll = post.poll!;
    final totalVotes = poll.totalVotes;
    final hasVoted = poll.options.any((o) => o.votes.contains(widget.currentUserId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(poll.question, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(poll.options.length, (i) {
            final option = poll.options[i];
            final percentage = totalVotes > 0 ? (option.votes.length / totalVotes * 100).round() : 0;
            final isSelected = option.votes.contains(widget.currentUserId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: hasVoted ? null : () => widget.onVotePoll(post.id, i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ),
                          if (hasVoted)
                            Text('$percentage%', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Text('${totalVotes} vote${totalVotes == 1 ? '' : 's'}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _commentTile(CommunityComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                child: Text(comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onAuthorTap(comment.userId),
                      child: Text(comment.userName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                    Text(_timeAgo(comment.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
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
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
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
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.onSurfaceVariant),
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
                    if (reason != null) Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentActions(CommunityComment comment) {
    final isOwner = comment.userId == widget.currentUserId;
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
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Comment', style: GoogleFonts.poppins(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text('Delete Comment?', style: GoogleFonts.poppins()),
                    content: Text('This action cannot be undone.', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text('Cancel', style: GoogleFonts.poppins())),
                      TextButton(onPressed: () => Navigator.pop(d, true), child: Text('Delete', style: GoogleFonts.poppins(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirm == true) {
                  final postId = widget.post?.id ?? '';
                  await widget.onDeleteComment(postId, comment.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.onSurfaceVariant),
              title: Text('Report Comment', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text('Report Comment?', style: GoogleFonts.poppins()),
                    content: Text('This comment will be reviewed by Aegis AI moderator.', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text('Cancel', style: GoogleFonts.poppins())),
                      TextButton(onPressed: () => Navigator.pop(d, true), child: Text('Report', style: GoogleFonts.poppins())),
                    ],
                  ),
                );
                if (confirm == true) {
                  final postId = widget.post?.id ?? '';
                  final reason = await widget.onReportComment(postId, comment.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(reason != null ? 'Comment removed by Aegis: $reason' : 'Comment reported and approved by Aegis'),
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
