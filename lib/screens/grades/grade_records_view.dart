import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'grade_table.dart';

class SemesterOption {
  final String label;
  final ReportLink? report;
  final int subjectCount;
  final bool pendingOnly;

  const SemesterOption({
    required this.label,
    required this.report,
    required this.subjectCount,
    required this.pendingOnly,
  });

  String get href => report?.href ?? label;
}

class GradeRecordsView extends StatefulWidget {
  final List<SemesterOption> semesters;
  final Map<String, List<SubjectGrade>> loadedGrades;
  final String? loadingSemesterHref;
  final ValueChanged<SemesterOption> onSemesterClick;

  const GradeRecordsView({
    super.key,
    required this.semesters,
    required this.loadedGrades,
    required this.loadingSemesterHref,
    required this.onSemesterClick,
  });

  @override
  State<GradeRecordsView> createState() => _GradeRecordsViewState();
}

class _GradeRecordsViewState extends State<GradeRecordsView> {
  SemesterOption? _selected;

  @override
  Widget build(BuildContext context) {
    if (_selected == null) return _buildSemesterList();
    return _buildSemesterDetail(_selected!);
  }

  Widget _buildSemesterList() {
    if (widget.semesters.isEmpty) {
      return const Center(child: Text('No grade records yet.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        Text('Semesters', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520 ? 2 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: columns == 2 ? 3.2 : 4.2,
              children: widget.semesters.map(_semesterCard).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _semesterCard(SemesterOption option) {
    final countText = option.pendingOnly
        ? '${option.subjectCount} subjects, No grades yet'
        : '${option.subjectCount} subjects';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() => _selected = option);
        if (!widget.loadedGrades.containsKey(option.href)) {
          widget.onSemesterClick(option);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(countText, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterDetail(SemesterOption option) {
    final loading = widget.loadingSemesterHref == option.href;
    final grades = widget.loadedGrades[option.href] ?? const <SubjectGrade>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: Theme.of(context).textTheme.titleMedium),
                    Text('${grades.length} subjects', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selected = null),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('All semesters'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : grades.isEmpty
                  ? const Center(child: Text('No grade records yet.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth - 32;
                        final tableWidth = availableWidth > 620 ? availableWidth : 620.0;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: tableWidth,
                              child: GradeTable(grades: grades),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
