import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class GradesHeader extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabs;
  final bool isSyncing;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSync;

  const GradesHeader({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    required this.isSyncing,
    required this.onTabSelected,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grades', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      'Official scholastic records and performance history',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: isSyncing ? null : onSync,
                icon: isSyncing
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 16),
                label: Text(isSyncing ? 'Updating...' : 'Sync Grades'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: tabs.asMap().entries.map((entry) {
              final selected = entry.key == selectedIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTabSelected(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class GradesEmptyState extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onSync;

  const GradesEmptyState({super.key, required this.isSyncing, required this.onSync});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No grade records yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Sync your portal data from the dashboard to view your grades.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isSyncing ? null : onSync,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(isSyncing ? 'Updating...' : 'Sync Grades'),
            ),
          ],
        ),
      ),
    );
  }
}
