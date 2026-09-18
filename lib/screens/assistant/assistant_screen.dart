import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
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
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(msg.content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ),
      );
    }

    final content = _stripThinking(msg.content);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.status != null && (widget.isGenerating || content.isEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(msg.status!, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ),
          if (content.trim().isNotEmpty)
            ..._generator.buildWidgets(content, config: _buildConfig(context)),
        ],
      ),
    );
  }

  String _stripThinking(String content) {
    return content
        .replaceAll(
          RegExp(r'<(thought|think|reasoning)>[\s\S]*?(?:</\1>|$)', caseSensitive: false),
          '',
        )
        .trim();
  }

  final MarkdownGenerator _generator = MarkdownGenerator();

  MarkdownConfig _buildConfig(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    return base.copy(configs: [
      PConfig(
        textStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurface, height: 1.5),
      ),
      H1Config(
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
      ),
      H2Config(
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
      ),
      H3Config(
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      ),
      CodeConfig(
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      PreConfig(
        theme: isDark ? a11yDarkTheme : a11yLightTheme,
        textStyle: GoogleFonts.spaceMono(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff3a3a3a) : const Color(0xfff3f4f6),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 56, 12),
        wrapper: (child, code, language) => _CodeBlockWrapper(child: child, code: code, language: language),
      ),
      BlockquoteConfig(
        textColor: AppColors.onSurfaceVariant,
        sideColor: AppColors.primary,
      ),
      LinkConfig(
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline),
        onTap: (url) async {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          }
        },
      ),
      TableConfig(
        wrapper: (table) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
      ),
    ]);
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

class _CodeBlockWrapper extends StatefulWidget {
  final Widget child;
  final String code;
  final String language;

  const _CodeBlockWrapper({required this.child, required this.code, required this.language});

  @override
  State<_CodeBlockWrapper> createState() => _CodeBlockWrapperState();
}

class _CodeBlockWrapperState extends State<_CodeBlockWrapper> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 6,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.language.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.language,
                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                  ),
                ),
              InkWell(
                onTap: _copy,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _copied ? PhosphorIcons.check() : PhosphorIcons.copy(),
                    size: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
