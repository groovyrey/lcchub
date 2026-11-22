import 'package:flutter_test/flutter_test.dart';

import 'package:portal_app/models/models.dart';
import 'package:portal_app/theme/grade_policy.dart';

void main() {
  test('grade policy keeps decimal grades and converts percentages', () {
    expect(GradePolicy.toDecimal(1.5), closeTo(1.5, 0.0001));
    expect(GradePolicy.toDecimal(92), closeTo(1.64, 0.0001));
  });

  test('grade summary matches portal average, best grade, and history', () {
    final grades = [
      SubjectGrade(
        code: 'MATH',
        description: 'Mathematics',
        grade: '1.50',
        units: '3',
        semester: '1st Semester, School Year 2024-2025',
      ),
      SubjectGrade(
        code: 'SCI',
        description: 'Science',
        grade: '2.00',
        units: '3',
        semester: '1st Semester, School Year 2024-2025',
      ),
      SubjectGrade(
        code: 'HIST',
        description: 'History',
        grade: '1.00',
        units: '3',
        semester: '2nd Semester, School Year 2024-2025',
      ),
      SubjectGrade(
        code: 'PHYS',
        description: 'Physics',
        grade: '92',
        units: '3',
        semester: '2nd Semester, School Year 2024-2025',
      ),
    ];

    final summary = GradePolicy.summarize(grades, enrolledUnits: 0);

    expect(summary.average, closeTo(1.535, 0.0001));
    expect(summary.highest, '1.00');
    expect(summary.trend.first.score, closeTo(96, 0.001));
    expect(summary.trend.last.score, closeTo(90.625, 0.001));
    expect(summary.trend.first.score, isNot(closeTo(summary.trend.last.score!, 0.001)));
  });
}
