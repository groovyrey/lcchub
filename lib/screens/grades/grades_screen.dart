import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class GradesScreen extends StatefulWidget {
  final List<ReportLink> reports;
  final Map<String, List<SubjectGrade>> loadedGrades;
  final String? loadingSemesterHref;
  final Function(ReportLink) onSemesterClick;

  const GradesScreen({
    super.key,
    required this.reports,
    required this.loadedGrades,
    required this.loadingSemesterHref,
    required this.onSemesterClick,
  });

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? selectedSemesterHref;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SubjectGrade> get _displayedGrades {
    if (selectedSemesterHref == null) return [];
    final grades = widget.loadedGrades[selectedSemesterHref] ?? [];
    if (_searchQuery.isEmpty) return grades;
    return grades.where((g) =>
      g.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      g.code.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (selectedSemesterHref != null)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(PhosphorIcons.x(), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.reports.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final report = widget.reports[index];
                final isSelected = selectedSemesterHref == report.href;
                final isLoading = widget.loadingSemesterHref == report.href;
                final isLoaded = widget.loadedGrades.containsKey(report.href);
                return FilterChip(
                  avatar: isLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : isLoaded ? Icon(PhosphorIcons.check(), size: 14, color: Colors.white) : null,
                  label: Text(report.text, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : AppColors.onSurface)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedSemesterHref = report.href);
                    if (!isLoaded) widget.onSemesterClick(report);
                  },
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
            child: selectedSemesterHref == null
                ? _buildEmptyState()
                : _displayedGrades.isEmpty && widget.loadingSemesterHref == selectedSemesterHref
                    ? const Center(child: CircularProgressIndicator())
                    : _displayedGrades.isEmpty
                        ? _buildNoGradesState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: _displayedGrades.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final grades = widget.loadedGrades[selectedSemesterHref] ?? [];
                                return _gradeStats(grades);
                              }
                              return _subjectCard(_displayedGrades[index - 1]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.graduationCap(PhosphorIconsStyle.fill), size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('Grade Reports', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Select a semester above to view your grades',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNoGradesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.magnifyingGlassMinus(), size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No subjects found', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _gradeStats(List<SubjectGrade> grades) {
    final allGrades = grades.map((g) => double.tryParse(g.grade)).whereType<double>().toList();
    final average = allGrades.isNotEmpty ? allGrades.reduce((a, b) => a + b) / allGrades.length : 0.0;
    final totalUnits = grades.fold(0, (sum, g) => sum + (int.tryParse(g.units ?? '') ?? 0));
    final highest = allGrades.isNotEmpty ? allGrades.reduce((a, b) => a < b ? a : b) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('GWA', average.toStringAsFixed(2)),
          _statItem('Units', totalUnits.toString()),
          _statItem('Subjects', grades.length.toString()),
          _statItem('Best', highest.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _subjectCard(SubjectGrade subject) {
    final gradeValue = double.tryParse(subject.grade);
    final gradeColor = switch (gradeValue) {
      != null when gradeValue <= 3.0 => AppColors.secondary,
      != null when gradeValue <= 4.0 => AppColors.warning,
      != null => AppColors.error,
      _ => AppColors.onSurface,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.bookmark(), color: gradeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.description.isNotEmpty ? subject.description : subject.code,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                if (subject.code.isNotEmpty && subject.code != subject.description)
                  Text(subject.code, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
                if (subject.remarks.isNotEmpty)
                  Text(subject.remarks, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(subject.grade, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor)),
          ),
        ],
      ),
    );
  }
}
