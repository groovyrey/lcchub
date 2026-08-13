import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Flutter port of the web ScheduleTable (grid + list views, detail sheet).
class ScheduleTable extends StatefulWidget {
  final List<ScheduleItem> schedule;

  const ScheduleTable({super.key, required this.schedule});

  @override
  State<ScheduleTable> createState() => _ScheduleTableState();
}

class _ScheduleTableState extends State<ScheduleTable> {
  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _hours = [
    '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM',
    '7:00 PM', '8:00 PM', '9:00 PM',
  ];

  static String? _cachedCurrentDay;

  bool _isGrid = true;

  String get _currentDay {
    if (_cachedCurrentDay != null) return _cachedCurrentDay!;
    try {
      tz.initializeTimeZones();
      final now = tz.TZDateTime.now(tz.getLocation('Asia/Manila'));
      _cachedCurrentDay = DateFormat('EEEE').format(now);
    } catch (_) {
      _cachedCurrentDay = DateFormat('EEEE').format(DateTime.now());
    }
    return _cachedCurrentDay!;
  }

  String _getSubjectCode(String subject) => subject.split(' - ').first.trim();

  String _getSubjectName(String subject) {
    final parts = subject.split(' - ');
    return parts.length > 1 ? parts.sublist(1).join(' - ').trim() : subject;
  }

  String _getDisplayTitle(ScheduleItem item) =>
      item.description.isNotEmpty ? item.description.trim() : _getSubjectName(item.subject);

  ({double start, double end})? _parseTimeRange(String timeStr) {
    final re = RegExp(r'(\d{1,2}:\d{2}\s*(?:AM|PM))\s*-\s*(\d{1,2}:\d{2}\s*(?:AM|PM))', caseSensitive: false);
    final m = re.firstMatch(timeStr);
    if (m == null) return null;

    double? parseTime(String t) {
      final mm = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false).firstMatch(t);
      if (mm == null) return null;
      var hour = int.parse(mm.group(1)!);
      final minute = int.parse(mm.group(2)!);
      final ampm = mm.group(3)!.toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      return hour + minute / 60;
    }

    final start = parseTime(m.group(1)!);
    final end = parseTime(m.group(2)!);
    return (start != null && end != null) ? (start: start, end: end) : null;
  }

  String? _getDay(String timeStr) {
    if (timeStr.isEmpty) return null;
    final abbr = timeStr.substring(0, 3).toUpperCase();
    const map = {
      'MON': 'Monday', 'TUE': 'Tuesday', 'WED': 'Wednesday', 'THU': 'Thursday',
      'FRI': 'Friday', 'SAT': 'Saturday', 'SUN': 'Sunday',
    };
    return map[abbr];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.calendarX(), size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No classes scheduled yet.', style: GoogleFonts.poppins(fontSize: 15, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.calendar(), size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Schedule', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              _viewToggle(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isGrid ? _buildGrid() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(PhosphorIcons.squaresFour(), 'Grid', _isGrid, () => setState(() => _isGrid = true)),
          _toggleBtn(PhosphorIcons.list(), 'List', !_isGrid, () => setState(() => _isGrid = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid view ─────────────────────────────────────────────────────

  Widget _buildGrid() {
    final currentDay = _currentDay;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.outline.withValues(alpha: 0.5))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 44, child: _timeColumn()),
            for (var d = 0; d < _days.length; d++)
              SizedBox(width: 64, child: _dayColumn(_days[d], currentDay)),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn() {
    return Column(
      children: [
        _headerCell('Time', false),
        for (final hour in _hours)
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: _cellDecor(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
            child: Text(
              hour.split(' ').first,
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _dayColumn(String day, String currentDay) {
    final isToday = day == currentDay;
    final cells = <Widget>[_headerCell(day.substring(0, 3), isToday)];
    var span = 0;

    for (var hIdx = 0; hIdx < _hours.length; hIdx++) {
      if (span > 0) {
        span--;
        continue;
      }

      final currentHour = 7 + hIdx;
      ScheduleItem? match;
      for (final item in widget.schedule) {
        final d = _getDay(item.time);
        final range = _parseTimeRange(item.time);
        if (d == day && range != null && range.start.floor() == currentHour) {
          match = item;
          break;
        }
      }

      if (match != null) {
        final range = _parseTimeRange(match.time);
        final duration = range != null ? range.end.ceil() - range.start.floor() : 1;
        span = duration - 1;
        cells.add(_classCell(match, isToday, duration));
      } else {
        cells.add(
          Container(
            height: 48,
            decoration: _cellDecor(color: isToday ? AppColors.primary.withValues(alpha: 0.05) : null),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cells,
    );
  }

  BoxDecoration _cellDecor({Color? color, bool right = true, bool bottom = true}) {
    return BoxDecoration(
      color: color,
      border: Border(
        right: right ? BorderSide(color: AppColors.outline.withValues(alpha: 0.5)) : BorderSide.none,
        bottom: bottom ? BorderSide(color: AppColors.outline.withValues(alpha: 0.5)) : BorderSide.none,
      ),
    );
  }

  Widget _headerCell(String label, bool isToday) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _cellDecor(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          if (isToday)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _classCell(ScheduleItem item, bool isToday, int duration) {
    return Container(
      height: (duration * 48).toDouble(),
      padding: const EdgeInsets.all(4),
      decoration: _cellDecor(color: isToday ? AppColors.primary.withValues(alpha: 0.05) : null),
      child: Material(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => _openDetail(item),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSubjectCode(item.subject),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
                ),
                if (_getDisplayTitle(item) != _getSubjectCode(item.subject)) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getDisplayTitle(item),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 9, color: AppColors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  item.room.isNotEmpty ? item.room : 'TBA',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── List view ─────────────────────────────────────────────────────

  Widget _buildList() {
    final currentDay = _currentDay;
    final children = <Widget>[];

    for (final day in _days) {
      final dayClasses = widget.schedule.where((item) => _getDay(item.time) == day).toList();
      if (dayClasses.isEmpty) continue;

      dayClasses.sort(
        (a, b) =>
            (_parseTimeRange(a.time)?.start ?? 0).compareTo(_parseTimeRange(b.time)?.start ?? 0),
      );

      children.add(_dayHeader(day, day == currentDay));
      children.addAll(dayClasses.map(_listCard));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _dayHeader(String day, bool isToday) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Text(
            day.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: isToday ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Today',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _listCard(ScheduleItem item) {
    final timeStart = item.time.isNotEmpty ? item.time.split(' - ').first.trim() : '';
    final hourLabel = timeStart.contains(' ') ? timeStart.split(' ').first : timeStart;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.clock(), size: 15, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 2),
                    Text(
                      hourLabel,
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSubjectCode(item.subject),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDisplayTitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _metaChip(PhosphorIcons.clock(), item.time.isNotEmpty ? item.time : 'TBA'),
                        _metaChip(PhosphorIcons.mapPin(), item.room.isNotEmpty ? item.room : 'TBA'),
                        if (item.instructor?.isNotEmpty == true)
                          _metaChip(PhosphorIcons.bookOpen(), item.instructor!),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIcons.arrowRight(), size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ── Detail sheet ──────────────────────────────────────────────────

  void _openDetail(ScheduleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getSubjectName(item.subject),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _getSubjectCode(item.subject),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Section ${item.section.isNotEmpty ? item.section : 'TBA'}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailRow(PhosphorIcons.clock(), 'Time Schedule', item.time.isNotEmpty ? item.time : 'TBA'),
                const SizedBox(height: 16),
                _detailRow(PhosphorIcons.mapPin(), 'Location / Room', item.room.isNotEmpty ? item.room : 'TBA'),
                const SizedBox(height: 16),
                _detailRow(PhosphorIcons.bookOpen(), 'Subject Name', _getDisplayTitle(item)),
                if (item.instructor?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _detailRow(PhosphorIcons.info(), 'Instructor', item.instructor!),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.outline.withValues(alpha: 0.5), height: 1),
                ),
                Row(
                  children: [
                    Expanded(child: _detailStat('Units', item.units.isNotEmpty ? item.units : '0')),
                    Expanded(child: _detailStat('Section', item.section.isNotEmpty ? item.section : 'TBA')),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'DISMISS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailStat(String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
          child: Icon(
            label == 'Units' ? PhosphorIcons.hash() : PhosphorIcons.bookOpen(),
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
