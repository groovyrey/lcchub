import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(String content, String? topic, bool isAnonymous, Map<String, dynamic>? poll) onSubmit;

  const CreatePostScreen({super.key, required this.onSubmit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [];
  String? _selectedTopic;
  bool _isAnonymous = false;
  bool _showPollEditor = false;

  final _topics = ['Academics', 'Campus Life', 'Career', 'Well-Being', 'General'];

  @override
  void initState() {
    super.initState();
    _pollOptionControllers.add(TextEditingController());
    _pollOptionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text('Post', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _canSubmit ? AppColors.primary : AppColors.onSurfaceVariant)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: _showPollEditor ? 'Add a description (optional)...' : 'What\'s on your mind?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _toolbarIcon(
                icon: _showPollEditor ? Icons.bar_chart : Icons.bar_chart_outlined,
                isActive: _showPollEditor,
                tooltip: 'Create Poll',
                onTap: () => setState(() {
                  _showPollEditor = !_showPollEditor;
                  if (!_showPollEditor) {
                    _pollQuestionController.clear();
                    for (final c in _pollOptionControllers) {
                      c.clear();
                    }
                  }
                }),
              ),
            ],
          ),
          if (_showPollEditor) ...[
            const SizedBox(height: 12),
            _buildPollEditor(),
          ],
          const SizedBox(height: 16),
          Text('Topic', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topics.map((topic) {
              final isSelected = _selectedTopic == topic;
              return FilterChip(
                label: Text(topic, style: GoogleFonts.poppins(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedTopic = isSelected ? null : topic),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : AppColors.onSurface),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Post Anonymously', style: GoogleFonts.poppins(fontSize: 14)),
            subtitle: Text('Your name will be hidden', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  bool get _canSubmit {
    final hasContent = _contentController.text.trim().isNotEmpty;
    if (!_showPollEditor) return hasContent;
    final hasQuestion = _pollQuestionController.text.trim().isNotEmpty;
    final validOptions = _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).length;
    return hasContent || (hasQuestion && validOptions >= 2);
  }

  Widget _toolbarIcon({required IconData icon, required bool isActive, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildPollEditor() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Poll Options', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pollQuestionController,
            decoration: InputDecoration(
              hintText: 'Ask a question...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ...List.generate(_pollOptionControllers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOptionControllers[i],
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_pollOptionControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _pollOptionControllers[i].dispose();
                      setState(() => _pollOptionControllers.removeAt(i));
                    },
                  ),
              ],
            ),
          )),
          if (_pollOptionControllers.length < 5)
            TextButton.icon(
              onPressed: () => setState(() => _pollOptionControllers.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Option', style: GoogleFonts.poppins(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  void _submit() {
    Map<String, dynamic>? poll;
    if (_showPollEditor && _pollQuestionController.text.trim().isNotEmpty) {
      final options = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (options.length >= 2) {
        poll = {'question': _pollQuestionController.text.trim(), 'options': options};
      }
    }
    widget.onSubmit(_contentController.text.trim(), _selectedTopic, _isAnonymous, poll);
    Navigator.of(context).pop();
  }
}
