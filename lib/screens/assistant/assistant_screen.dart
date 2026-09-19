import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/latex.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

final _suggestions = <({String label, IconData icon, String prompt})>[
  (label: 'My grades', icon: PhosphorIcons.chartBar(), prompt: 'What are my grades?'),
  (label: 'My schedule', icon: PhosphorIcons.calendar(), prompt: 'What\'s my schedule?'),
  (label: 'My balance', icon: PhosphorIcons.wallet(), prompt: 'How much do I owe?'),
  (label: 'Study help', icon: PhosphorIcons.graduationCap(), prompt: 'Help me study'),
];

class AssistantScreen extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? error;
  final String? studentName;
  final Function(String) onSendMessage;
  final VoidCallback onStop;
  final VoidCallback onClearChat;

  const AssistantScreen({
    super.key,
    required this.messages,
    required this.isGenerating,
    this.error,
    this.studentName,
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
            duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: widget.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) => _FadeSlideIn(
                    key: ValueKey('msg-${index}-${widget.messages[index].id}'),
                    child: _messageBubble(widget.messages[index]),
                  ),
                ),
        ),
        if (widget.error != null) _buildErrorBar(),
        _buildComposer(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(PhosphorIcons.robot(), size: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text('LCC Assistant', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
          if (widget.isGenerating) ...[
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: widget.onClearChat,
            icon: Icon(PhosphorIcons.trash(), size: 15),
            label: Text('Clear', style: GoogleFonts.poppins(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    final dimmed = _controller.text.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline.withValues(alpha: 0.6))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.poppins(fontSize: 14.5, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (widget.isGenerating)
              _ActionButton(
                onTap: widget.onStop,
                gradient: const [Color(0xFFFF5B5B), Color(0xFFEF4444)],
                icon: PhosphorIcons.stopCircle(),
                tooltip: 'Stop',
              )
            else
              _ActionButton(
                onTap: dimmed ? null : _send,
                gradient: [AppColors.primary, AppColors.gradientEnd],
                icon: PhosphorIcons.paperPlaneRight(),
                tooltip: 'Send',
                dimmed: dimmed,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.error!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final firstName = (widget.studentName ?? '').trim().isNotEmpty
        ? (widget.studentName!.trim().split(RegExp(r'\s+')).first)
        : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          _buildOrb(),
          const SizedBox(height: 24),
          Text(
            firstName == null ? 'Hi, I\'m your LCC assistant' : 'Hi $firstName, welcome back',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about your grades, schedule, fees, or anything about campus life.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              for (var i = 0; i < _suggestions.length; i++)
                _FadeSlideIn(
                  key: ValueKey('sug-$i'),
                  delay: Duration(milliseconds: 80 + i * 70),
                  offset: const Offset(0, 0.12),
                  child: _quickActionTile(_suggestions[i]),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Responses can be delayed or inaccurate — verify important details.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.55),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0, 0.85],
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(PhosphorIcons.robot(), size: 30, color: Colors.white),
          ),
          Positioned(
            top: 14,
            right: 16,
            child: _glowDot(AppColors.secondary, radius: 5),
          ),
          Positioned(
            bottom: 18,
            left: 10,
            child: _glowDot(AppColors.primary, radius: 4),
          ),
          Positioned(
            top: 26,
            left: 6,
            child: _glowDot(AppColors.gradientWarm, radius: 3),
          ),
        ],
      ),
    );
  }

  Widget _glowDot(Color color, {required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }

  Widget _quickActionTile(({String label, IconData icon, String prompt}) item) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _sendWith(item.prompt),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(PhosphorIcons.arrowRight(), size: 13, color: AppColors.onSurfaceVariant),
            ],
          ),
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
          margin: const EdgeInsets.only(bottom: 14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Text(msg.content, style: GoogleFonts.poppins(fontSize: 14.5, color: Colors.white, height: 1.4)),
        ),
      );
    }

    final content = _stripThinking(msg.content);
    final showStatus = msg.status != null && (widget.isGenerating || content.isEmpty);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(PhosphorIcons.robot(), size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showStatus) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      msg.status!,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ),
                  if (widget.isGenerating && content.isEmpty)
                    const _TypingDots(),
                ],
                if (content.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _generator.buildWidgets(content, config: _buildConfig(context)),
                    ),
                  ),
              ],
            ),
          ),
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

  final MarkdownGenerator _generator = MarkdownGenerator(
    generators: [latexGenerator],
    inlineSyntaxList: [LatexSyntax()],
  );

  MarkdownConfig _buildConfig(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final body = GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurface, height: 1.6);
    final mono = GoogleFonts.spaceMono(fontSize: 12.5);
    return MarkdownConfig(configs: [
      PConfig(textStyle: body),
      H1Config(
        style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.4),
      ),
      H2Config(
        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.3),
      ),
      H3Config(
        style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: -0.2),
      ),
      H4Config(
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      ),
      H5Config(
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      ),
      H6Config(
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
      ),
      CodeConfig(
        style: mono.copyWith(
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          backgroundColor: AppColors.surfaceVariant,
        ),
      ),
      PreConfig(
        theme: isDark ? a11yDarkTheme : a11yLightTheme,
        textStyle: GoogleFonts.spaceMono(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff2a2d3a) : const Color(0xfff3f4f8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 56, 12),
        wrapper: (child, code, language) => _CodeBlockWrapper(child: child, code: code, language: language),
      ),
      BlockquoteConfig(
        textColor: AppColors.onSurfaceVariant,
        sideColor: AppColors.primary,
      ),
      LinkConfig(
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline, decorationColor: AppColors.primary),
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
        border: TableBorder.all(color: AppColors.outline, width: 1),
        headerStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        bodyStyle: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.onSurface, height: 1.4),
        wrapper: (table) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: table),
          ),
        ),
      ),
      HrConfig(color: AppColors.outline),
    ]);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    setState(() => _controller.clear());
    widget.onSendMessage(text);
    _scrollToBottom();
  }

  void _sendWith(String text) {
    widget.onSendMessage(text);
    _scrollToBottom();
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final List<Color> gradient;
  final IconData icon;
  final String tooltip;
  final bool dimmed;

  const _ActionButton({
    required this.onTap,
    required this.gradient,
    required this.icon,
    required this.tooltip,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: dimmed ? 0.45 : 1,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Opacity(
                    opacity: 0.35 + 0.55 * ((math.sin((_controller.value * 2 * math.pi) - i * 1.1) + 1) / 2),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: AppColors.onSurfaceVariant, shape: BoxShape.circle),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const _FadeSlideIn({super.key, required this.child, this.delay = Duration.zero, this.offset = const Offset(0, 0.06)});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06);
    final chipFg = isDark ? Colors.white70 : Colors.black54;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 6,
          right: 8,
          child: Container(
            padding: const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 3),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty) ...[
                  Text(
                    widget.language,
                    style: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w600, color: chipFg),
                  ),
                  const SizedBox(width: 6),
                  Container(width: 1, height: 12, color: chipFg.withValues(alpha: 0.25)),
                  const SizedBox(width: 2),
                ],
                InkWell(
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      _copied ? PhosphorIcons.check() : PhosphorIcons.copy(),
                      size: 13,
                      color: _copied ? AppColors.success : chipFg,
                    ),
                  ),
                ),
              ],
            ),
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