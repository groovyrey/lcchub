import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/grade_summary.dart';

class GradeTrendChart extends StatelessWidget {
  final List<GradeTrendPoint> points;

  const GradeTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'History',
      subtitle: 'Grade score by semester',
      child: points.isEmpty
          ? const SizedBox(height: 180, child: Center(child: Text('No history yet')))
          : Column(
              children: [
                SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: _TrendPainter(points: points),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: points
                      .map((point) => Text(point.label, style: Theme.of(context).textTheme.labelSmall))
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class GradeBreakdownChart extends StatelessWidget {
  final List<GradeDistribution> items;

  const GradeBreakdownChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(0, (max, item) => item.count > max ? item.count : max);
    return _ChartCard(
      title: 'Breakdown',
      subtitle: 'Grades count',
      child: items.isEmpty
          ? const SizedBox(height: 180, child: Center(child: Text('No grades yet')))
          : SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final height = maxCount == 0 ? 8.0 : 120 * item.count / maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${item.count}', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Container(
                            height: height < 8 ? 8 : height,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.grade, style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<GradeTrendPoint> points;

  _TrendPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final valid = points.where((point) => point.score != null).toList();
    if (valid.isEmpty) return;

    final step = valid.length == 1 ? 0.0 : size.width / (valid.length - 1);
    final offsets = <Offset>[];
    for (var i = 0; i < valid.length; i += 1) {
      final x = valid.length == 1 ? size.width / 2 : i * step;
      const padding = 12.0;
      final normalized = (valid[i].score ?? 0) / 100;
      final y = size.height - padding - normalized * (size.height - padding * 2);
      offsets.add(Offset(x, y));
    }

    final area = Path()
      ..moveTo(offsets.first.dx, size.height)
      ..lineTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      area.lineTo(offset.dx, offset.dy);
    }
    area
      ..lineTo(offsets.last.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = AppColors.primary.withValues(alpha: 0.10),
    );

    final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      line.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (final offset in offsets) {
      canvas.drawCircle(
        offset,
        3,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => oldDelegate.points != points;
}
