import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/grade_summary.dart';
import 'grade_charts.dart';

class GradeStatsView extends StatefulWidget {
  final GradeSummary summary;
  final bool hasGrades;

  const GradeStatsView({
    super.key,
    required this.summary,
    required this.hasGrades,
  });

  @override
  State<GradeStatsView> createState() => _GradeStatsViewState();
}

class _GradeStatsViewState extends State<GradeStatsView> {
  bool _showGwa = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasGrades) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No stats yet. Sync your grades to see your performance summary and averages.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final summary = widget.summary;
    final unitsLabel = summary.enrolledUnits > 0
        ? 'Current load (${summary.earnedUnits.toStringAsFixed(0)} earned)'
        : 'Total earned units';
    final unitsValue = summary.enrolledUnits > 0 ? summary.enrolledUnits : summary.earnedUnits;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: crossAxisCount == 4 ? 1.25 : 1.45,
              children: [
                _MetricCard(
                  label: 'Average',
                  value: _showGwa ? (summary.average?.toStringAsFixed(2) ?? 'N/A') : '***',
                  sublabel: 'Grade Average',
                  footnote: 'Uses subject units when available, 3 units assumed otherwise.',
                  trailing: IconButton(
                    tooltip: _showGwa ? 'Hide grade average' : 'Show grade average',
                    icon: Icon(_showGwa ? Icons.visibility : Icons.visibility_off, size: 18),
                    onPressed: () => setState(() => _showGwa = !_showGwa),
                  ),
                ),
                _MetricCard(
                  label: 'Units',
                  value: unitsValue.toStringAsFixed(1),
                  sublabel: unitsLabel,
                ),
                _MetricCard(
                  label: 'Highest',
                  value: summary.highest,
                  sublabel: 'Best grade',
                ),
                _MetricCard(
                  label: 'Pass Rate',
                  value: '${summary.passRate}%',
                  sublabel: 'Subjects passed',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: GradeTrendChart(points: widget.summary.trend)),
                if (wide) const SizedBox(width: 12) else const SizedBox(height: 12),
                Expanded(child: GradeBreakdownChart(items: widget.summary.distribution)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String? footnote;
  final Widget? trailing;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.sublabel,
    this.footnote,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
              if (trailing != null) trailing!,
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(sublabel, style: Theme.of(context).textTheme.bodySmall),
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(footnote!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
