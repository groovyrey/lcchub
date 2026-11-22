import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../theme/grade_policy.dart';

class GradeTable extends StatelessWidget {
  final List<SubjectGrade> grades;

  const GradeTable({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.4,
        ) ??
        TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(104),
          1: FlexColumnWidth(2.2),
          2: FixedColumnWidth(86),
          3: FixedColumnWidth(96),
          4: FlexColumnWidth(1.25),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: AppColors.outline),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.surfaceVariant),
            children: [
              _headerCell('Code', headerStyle),
              _headerCell('Subject', headerStyle),
              _headerCell('Section', headerStyle, TextAlign.center),
              _headerCell('Grade', headerStyle, TextAlign.center),
              _headerCell('Status', headerStyle, TextAlign.right),
            ],
          ),
          for (var index = 0; index < grades.length; index += 1)
            TableRow(
              decoration: BoxDecoration(
                color: index.isEven
                    ? AppColors.surface
                    : AppColors.surfaceVariant.withValues(alpha: 0.35),
              ),
              children: _gradeCells(grades[index], textTheme),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, TextStyle style, [TextAlign align = TextAlign.left]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(label, textAlign: align, style: style),
    );
  }

  List<Widget> _gradeCells(SubjectGrade grade, TextTheme textTheme) {
    final pending = GradePolicy.isPending(grade);
    final passing = GradePolicy.isPassing(grade);
    final statusColor = pending
        ? AppColors.onSurfaceVariant
        : passing
            ? AppColors.success
            : AppColors.error;
    final statusIcon = pending
        ? Icons.schedule
        : passing
            ? Icons.check_circle_outline
            : Icons.cancel_outlined;
    final statusLabel = pending
        ? 'Pending'
        : grade.remarks.isNotEmpty
            ? grade.remarks
            : 'Recorded';

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          grade.code.isEmpty ? '---' : grade.code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          grade.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          grade.section ?? '---',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          pending ? 'No grade yet' : grade.grade,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: statusColor,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(statusIcon, size: 14, color: statusColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                statusLabel,
                textAlign: TextAlign.right,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
