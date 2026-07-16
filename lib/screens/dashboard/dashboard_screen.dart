import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  final Student? student;
  final VoidCallback onRefresh;

  const DashboardScreen({super.key, this.student, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: 'Overview'), Tab(text: 'Schedule')],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildOverview(context), _buildSchedule()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    final s = student!;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _gradientCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('ID: ${s.id}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                      if (s.course.isNotEmpty)
                        Text(s.course, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Quick Info', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoTile(Icons.calendar_today, 'School Year', s.schoolYear ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(child: _infoTile(Icons.school, 'Year Level', s.yearLevel ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoTile(Icons.event, 'Semester', s.semester ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(child: _infoTile(Icons.group, 'Section', s.section ?? 'N/A')),
            ],
          ),
          if (s.schedule != null && s.schedule!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Today\'s Classes', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            ...s.schedule!.take(5).map((item) => _scheduleTile(item)),
          ],
          if (s.financials != null) ...[
            const SizedBox(height: 16),
            Text('Financial Summary', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            _financialTile('Total', s.financials!.total),
            _financialTile('Balance', s.financials!.balance),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    final schedule = student?.schedule;
    if (schedule == null || schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No schedule available', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedule.length,
      itemBuilder: (context, index) => _scheduleDetailTile(schedule[index]),
    );
  }

  Widget _gradientCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _scheduleTile(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 36,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.subject, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item.time.isNotEmpty ? item.time : 'TBA', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (item.room.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(item.room, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _scheduleDetailTile(ScheduleItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.subject, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                if (item.units.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${item.units} units', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.description, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _detailChip(Icons.access_time, item.time.isNotEmpty ? item.time : 'TBA'),
                _detailChip(Icons.room, item.room.isNotEmpty ? item.room : 'TBA'),
                if (item.instructor != null && item.instructor!.isNotEmpty)
                  _detailChip(Icons.person, item.instructor!),
                if (item.section.isNotEmpty)
                  _detailChip(Icons.group, item.section),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _financialTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.onSurfaceVariant)),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
