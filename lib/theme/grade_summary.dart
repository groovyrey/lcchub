class GradeTrendPoint {
  final String label;
  final double? score;

  const GradeTrendPoint({required this.label, required this.score});
}

class GradeDistribution {
  final String grade;
  final int count;

  const GradeDistribution({required this.grade, required this.count});
}

class GradeSummary {
  final double? average;
  final double enrolledUnits;
  final double earnedUnits;
  final String highest;
  final int passRate;
  final List<GradeTrendPoint> trend;
  final List<GradeDistribution> distribution;

  const GradeSummary({
    required this.average,
    required this.enrolledUnits,
    required this.earnedUnits,
    required this.highest,
    required this.passRate,
    required this.trend,
    required this.distribution,
  });
}
