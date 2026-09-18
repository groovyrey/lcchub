import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StaffBadge extends StatelessWidget {
  final double size;

  const StaffBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
        size: size * 0.7,
        color: Colors.blue.shade600,
      ),
    );
  }
}