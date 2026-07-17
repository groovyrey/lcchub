import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class AssistantScreen extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? error;
  final Function(String) onSendMessage;
  final VoidCallback onStop;
  final VoidCallback onClearChat;

  const AssistantScreen({
    super.key,
    required this.messages,
    required this.isGenerating,
    this.error,
    required this.onSendMessage,
    required this.onStop,
    required this.onClearChat,
  });

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _suggestions = [
    'What are my grades?',
    'What\'s my schedule?',
    'How much do I owe?',
    'Help me study',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.messages.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(PhosphorIcons.robot(), size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('LCC Assistant', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                const Spacer(),
                TextButton.icon(
                  onPressed: widget.onClearChat,
                  icon: Icon(PhosphorIcons.trash(), size: 16),
                  label: Text('Clear', style: GoogleFonts.poppins(fontSize: 12)),
                ),
              ],
            ),
          ),
        Expanded(
          child: widget.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) => _messageBubble(widget.messages[index]),
                ),
        ),
        if (widget.error != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.error.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(PhosphorIcons.warningCircle(), size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.error!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error))),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isGenerating)
                  IconButton(
                    onPressed: widget.onStop,
                    icon: Icon(PhosphorIcons.stopCircle(), color: AppColors.error),
                  )
                else
                  IconButton(
                    onPressed: _send,
                    icon: Icon(PhosphorIcons.paperPlaneRight(), color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIcons.robot(), size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('LCC Assistant', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ask me about your grades, schedule, finances, or anything else!',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.map((s) => ActionChip(
                label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                onPressed: () => _sendWith(s),
                backgroundColor: AppColors.surfaceVariant,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(msg.status ?? 'Assistant', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isUser
                  ? Text(msg.content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white))
                  : MarkdownBody(
                      data: msg.content,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurface, height: 1.5),
                        h1: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        h2: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        h3: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        h4: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        h5: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        h6: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                        em: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.onSurface),
                        strong: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        blockquote: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurfaceVariant),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
                          color: AppColors.primary.withValues(alpha: 0.05),
                        ),
                        blockquotePadding: const EdgeInsets.all(12),
                        code: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5)),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        codeblockPadding: const EdgeInsets.all(12),
                        listBullet: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurface),
                        listIndent: 24,
                        listBulletPadding: const EdgeInsets.only(right: 8),
                        tableHead: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        tableBody: GoogleFonts.poppins(fontSize: 13, color: AppColors.onSurface),
                        tableBorder: TableBorder.all(color: AppColors.outline.withValues(alpha: 0.3), width: 1),
                        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.outline.withValues(alpha: 0.3), width: 1)),
                        ),
                        a: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    _controller.clear();
    widget.onSendMessage(text);
    _scrollToBottom();
  }

  void _sendWith(String text) {
    widget.onSendMessage(text);
    _scrollToBottom();
  }
}
