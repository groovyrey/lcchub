import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/grade_policy.dart';
import 'grade_records_view.dart';
import 'grade_stats_view.dart';
import 'grades_header.dart';

class GradesScreen extends StatefulWidget {
  final Student? student;
  final List<ReportLink> reports;
  final Map<String, List<SubjectGrade>> loadedGrades;
  final String? loadingSemesterHref;
  final bool isSyncing;
  final ValueChanged<ReportLink> onSemesterClick;
  final Future<void> Function() onSync;

  const GradesScreen({
    super.key,
    required this.student,
    required this.reports,
    required this.loadedGrades,
    required this.loadingSemesterHref,
    required this.isSyncing,
    required this.onSemesterClick,
    required this.onSync,
  });

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Stats', 'Records'];

  @override
  Widget build(BuildContext context) {
    final grades = _allGrades();
    final enrolledUnits = _enrolledUnits();
    final summary = GradePolicy.summarize(grades, enrolledUnits: enrolledUnits);
    final semesters = _semesterOptions(grades);

    if (grades.isEmpty && widget.reports.isEmpty) {
      return GradesEmptyState(isSyncing: widget.isSyncing, onSync: widget.onSync);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradesHeader(
          selectedIndex: _tabIndex,
          tabs: _tabs,
          isSyncing: widget.isSyncing,
          onTabSelected: (index) => setState(() => _tabIndex = index),
          onSync: widget.onSync,
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              GradeStatsView(summary: summary, hasGrades: grades.isNotEmpty),
              GradeRecordsView(
                semesters: semesters,
                loadedGrades: widget.loadedGrades,
                loadingSemesterHref: widget.loadingSemesterHref,
                onSemesterClick: (option) {
                  if (option.report != null) widget.onSemesterClick(option.report!);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<SubjectGrade> _allGrades() {
    final seen = <String>{};
    final result = <SubjectGrade>[];

    void add(SubjectGrade grade) {
      final key = '${grade.code}-${grade.description}-${grade.semester}'.toLowerCase();
      if (seen.add(key)) result.add(grade);
    }

    final stored = widget.student?.allGrades ?? const <SubjectGrade>[];
    if (stored.isNotEmpty) {
      for (final grade in stored) {
        add(grade.copyWith(semester: GradePolicy.semesterLabel(grade.semester)));
      }
    } else {
      for (final group in widget.student?.grades ?? const <SemesterGrade>[]) {
        for (final grade in group.subjects) {
          add(grade.copyWith(semester: group.semester));
        }
      }
    }

    widget.loadedGrades.forEach((href, grades) {
      ReportLink? report;
      for (final candidate in widget.reports) {
        if (candidate.href == href) {
          report = candidate;
          break;
        }
      }
      for (final grade in grades) {
        add(grade.copyWith(semester: report?.text));
      }
    });

    return result;
  }

  double _enrolledUnits() {
    return (widget.student?.schedule ?? const <ScheduleItem>[]).fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.units.trim()) ?? 0),
    );
  }

  List<SemesterOption> _semesterOptions(List<SubjectGrade> grades) {
    final groups = GradePolicy.groupBySemester(grades);
    if (groups.isNotEmpty) {
      return groups.map((group) {
        ReportLink? report;
        for (final candidate in widget.reports) {
          final label = GradePolicy.semesterLabel(candidate.text);
          if (label == group.semester || label.contains(group.semester) || group.semester.contains(label)) {
            report = candidate;
            break;
          }
        }
        return SemesterOption(
          label: group.semester,
          report: report,
          subjectCount: group.subjects.length,
          pendingOnly: group.subjects.every(GradePolicy.isPending),
        );
      }).toList();
    }

    return widget.reports.map((report) {
      final label = GradePolicy.semesterLabel(report.text);
      final loaded = widget.loadedGrades[report.href] ?? const <SubjectGrade>[];
      return SemesterOption(
        label: label,
        report: report,
        subjectCount: loaded.length,
        pendingOnly: loaded.isNotEmpty && loaded.every(GradePolicy.isPending),
      );
    }).toList();
  }
}
