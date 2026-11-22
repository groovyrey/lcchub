import '../models/models.dart';
import 'grade_summary.dart';

class SemesterGroup {
  final String semester;
  final List<SubjectGrade> subjects;

  const SemesterGroup({required this.semester, required this.subjects});
}

class GradePolicy {
  static const _pendingRemarks = {
    'NO GRADE YET',
    'NO GRADE',
    'N/A',
    'INC',
    'INCOMPLETE',
    'DRP',
    'DROPPED',
    'NG',
  };

  static String normalize(String value) => value.trim().toUpperCase();

  static double? parse(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed.isNegative) return null;
    return parsed;
  }

  static bool isPending(SubjectGrade grade) {
    final rawGrade = grade.grade.trim();
    final remark = normalize(grade.remarks);
    return rawGrade == '---' ||
        _pendingRemarks.contains(remark) ||
        parse(rawGrade) == null;
  }

  static bool isPercentage(double value) => value > 5;

  static double toDecimal(double value) {
    if (!isPercentage(value)) return value;
    final converted = 1 + (100 - value) / 12.5;
    return converted.clamp(1, 5).toDouble();
  }

  static double score(double value) {
    if (value <= 0) return 0;
    if (isPercentage(value)) return value.clamp(0, 100).toDouble();
    return (100 - (value - 1) * 12.5).clamp(0, 100).toDouble();
  }

  static double? decimal(SubjectGrade grade) {
    if (isPending(grade)) return null;
    final value = parse(grade.grade);
    return value == null ? null : toDecimal(value);
  }

  static bool isPassing(SubjectGrade grade) {
    if (isPending(grade)) return false;
    final remark = normalize(grade.remarks);
    if (remark.contains('PASS')) return true;
    if (remark.contains('FAIL')) return false;
    final value = parse(grade.grade);
    if (value == null) return false;
    return isPercentage(value) ? value >= 75 : value <= 3;
  }

  static double? weightedAverage(Iterable<SubjectGrade> grades) {
    var totalPoints = 0.0;
    var totalUnits = 0.0;
    for (final grade in grades) {
      final value = decimal(grade);
      if (value == null) continue;
      final units = double.tryParse(grade.units?.trim() ?? '') ?? 3;
      final weight = units > 0 ? units : 3;
      totalPoints += value * weight;
      totalUnits += weight;
    }
    if (totalUnits <= 0) return null;
    return totalPoints / totalUnits;
  }

  static String semesterLabel(String? value) {
    var label = (value ?? '').trim();
    if (label.isEmpty || label.toLowerCase().startsWith('unknown') || label.toLowerCase().startsWith('unlabeled')) {
      return 'Unknown Semester';
    }
    if (label.toLowerCase().startsWith('grades of ')) {
      label = label.substring(10);
    }
    return label
        .replaceAll(', School Year ', ' ')
        .replaceAll('First Semester', '1st Semester')
        .replaceAll('Second Semester', '2nd Semester');
  }

  static String shortSemesterLabel(String label) {
    return label
        .replaceAll(RegExp(r'20(\d{2})-20(\d{2})'), r'$1-$2')
        .replaceAll('1st Semester', '1st')
        .replaceAll('2nd Semester', '2nd')
        .replaceAll('Summer', 'Sum');
  }

  static List<String> sortSemesters(Iterable<String> values) {
    final labels = values.map(semesterLabel).toSet().toList();
    labels.sort((a, b) {
      final year = _yearKey(b).compareTo(_yearKey(a));
      if (year != 0) return year;
      final term = _termRank(b).compareTo(_termRank(a));
      if (term != 0) return term;
      return a.compareTo(b);
    });
    return labels;
  }

  static List<SemesterGroup> groupBySemester(Iterable<SubjectGrade> grades) {
    final buckets = <String, List<SubjectGrade>>{};
    for (final grade in grades) {
      final label = semesterLabel(grade.semester);
      buckets.putIfAbsent(label, () => []).add(grade.copyWith(semester: label));
    }
    return sortSemesters(buckets.keys)
        .where((label) => buckets[label]!.isNotEmpty)
        .map((label) => SemesterGroup(semester: label, subjects: buckets[label]!))
        .toList();
  }

  static GradeSummary summarize(
    Iterable<SubjectGrade> grades, {
    required double enrolledUnits,
  }) {
    final subjects = grades.toList();
    final average = weightedAverage(subjects);
    var earnedUnits = 0.0;
    var passed = 0;
    final outcomes = <SubjectGrade>[];
    final counts = <String, int>{};

    for (final grade in subjects) {
      counts[grade.grade] = (counts[grade.grade] ?? 0) + 1;
      if (isPending(grade)) continue;
      if (parse(grade.grade) != null) outcomes.add(grade);
      if (isPassing(grade)) {
        passed += 1;
        final units = double.tryParse(grade.units?.trim() ?? '') ?? 3;
        earnedUnits += units > 0 ? units : 3;
      }
    }

    final graded = subjects.where((grade) => !isPending(grade)).toList();
    SubjectGrade? best;
    double? bestScore;
    for (final grade in graded) {
      final value = parse(grade.grade);
      if (value == null) continue;
      final valueScore = score(value);
      if (bestScore == null || valueScore > bestScore) {
        best = grade;
        bestScore = valueScore;
      }
    }

    final distribution = counts.entries
        .map((entry) => GradeDistribution(grade: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) => (parse(a.grade) ?? 99).compareTo(parse(b.grade) ?? 99));

    final trend = groupBySemester(subjects).map((group) {
      final semesterAverage = weightedAverage(group.subjects);
      return GradeTrendPoint(
        label: shortSemesterLabel(group.semester),
        score: semesterAverage == null ? null : score(semesterAverage),
      );
    }).toList();

    return GradeSummary(
      average: average,
      enrolledUnits: enrolledUnits,
      earnedUnits: earnedUnits,
      highest: best?.grade.trim() ?? 'N/A',
      passRate: outcomes.isEmpty ? 0 : (passed / outcomes.length * 100).round(),
      trend: trend,
      distribution: distribution,
    );
  }

  static int _yearKey(String label) {
    final match = RegExp(r'20\d{2}').firstMatch(label);
    return match == null ? 0 : int.tryParse(match.group(0) ?? '') ?? 0;
  }

  static int _termRank(String label) {
    final text = label.toLowerCase();
    if (text.contains('unknown') || text.contains('unlabeled')) return 3;
    if (text.contains('2nd') || text.contains('second')) return 2;
    if (text.contains('1st') || text.contains('first')) return 1;
    if (text.contains('summer')) return 0;
    return 3;
  }
}
