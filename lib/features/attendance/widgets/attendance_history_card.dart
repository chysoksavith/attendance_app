import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/attendance_model.dart';

class AttendanceHistoryCard extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceHistoryCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final status = attendance.status;
    final Color badgeColor;
    switch (status.color) {
      case 'success':
        badgeColor = const Color(0xFF10B981);
      case 'warning':
        badgeColor = const Color(0xFFF59E0B);
      case 'error':
        badgeColor = const Color(0xFFEF4444);
      case 'info':
        badgeColor = const Color(0xFF3B82F6);
      default:
        badgeColor = AppColors.textSecondary;
    }

    final inTime = attendance.checkIn.at != null
        ? _formatTime(attendance.checkIn.at!)
        : '--:--';
    final outTime = attendance.checkOut.at != null
        ? _formatTime(attendance.checkOut.at!)
        : '--:--';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    attendance.date ?? 'Unknown date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Timestamps row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoColumn(
                label: 'Check In',
                value: inTime,
                icon: Icons.login_rounded,
                color: const Color(0xFF10B981),
              ),
              _InfoColumn(
                label: 'Check Out',
                value: outTime,
                icon: Icons.logout_rounded,
                color: const Color(0xFFF59E0B),
              ),
              _InfoColumn(
                label: 'Duration',
                value: attendance.formattedDuration,
                icon: Icons.timer_outlined,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
