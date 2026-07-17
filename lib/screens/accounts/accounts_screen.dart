import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class AccountsScreen extends StatelessWidget {
  final Financials? financials;
  final VoidCallback onRefresh;

  const AccountsScreen({super.key, this.financials, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (financials == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.receipt(), size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No financial data available', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    final f = financials!;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(f),
          const SizedBox(height: 16),
          if (f.payments != null && f.payments!.isNotEmpty) ...[
            Text('Payments', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            ...f.payments!.map((p) => _paymentTile(p)),
          ],
          if (f.installments != null && f.installments!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Installments', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            ...f.installments!.map((i) => _installmentTile(i)),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(Financials f) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryItem('Total', f.total),
              _summaryItem('Balance', f.balance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _paymentTile(Payment p) {
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
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.amount, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Ref: ${p.reference}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(p.date, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _installmentTile(Installment i) {
    final isPaid = i.outstanding.trim() == '0.00' || i.outstanding.trim() == '0';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPaid
          ? AppColors.success.withValues(alpha: 0.5)
          : AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? PhosphorIcons.checkCircle() : PhosphorIcons.clock(),
              color: isPaid ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.description, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                Text('Due: ${i.dueDate}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          isPaid
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Paid ✓', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
              )
            : Text(i.outstanding, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error)),
        ],
      ),
    );
  }
}
