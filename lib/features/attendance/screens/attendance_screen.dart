import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_history_card.dart';
import '../widgets/clock_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final today = attendance.todayAttendance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => attendance.refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  context.tr('attendance'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFullDate(_currentTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Clock Center Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withAlpha(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 25 : 6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Digital clock
                      Text(
                        _formatTimeWithSeconds(_currentTime),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge Pill
                      _buildStatusPill(context, attendance, isDark),

                      const SizedBox(height: 24),

                      // Animated Clock In / Out Button
                      ClockButton(
                        isCheckedIn: attendance.isCheckedIn,
                        isCheckedOut: attendance.isCheckedOut,
                        isClocking: attendance.isClocking,
                        onTap: () => _handleClockAction(context, attendance),
                      ),

                      const SizedBox(height: 24),

                      // Today's Check in/out stats mini row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MiniTimeBlock(
                              label: context.tr('clock_in'),
                              value: today?.checkIn.at != null
                                  ? _formatHourMinute(today!.checkIn.at!)
                                  : '--:--',
                              isDark: isDark,
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                            ),
                            _MiniTimeBlock(
                              label: context.tr('clock_out'),
                              value: today?.checkOut.at != null
                                  ? _formatHourMinute(today!.checkOut.at!)
                                  : '--:--',
                              isDark: isDark,
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                            ),
                            _MiniTimeBlock(
                              label: context.tr('total_hours'),
                              value: today?.formattedDuration ?? '0h 0m',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('recent_logs'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (attendance.history.isNotEmpty)
                      Text(
                        '${attendance.history.length} records',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (attendance.state == AttendanceViewState.loading &&
                    attendance.history.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (attendance.history.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border.withAlpha(80),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 40,
                          color: isDark
                              ? AppColors.darkTextSecondary.withAlpha(120)
                              : AppColors.textMuted.withAlpha(120),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('no_logs'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ...attendance.history.map(
                    (item) => AttendanceHistoryCard(attendance: item),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleClockAction(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final isClockingOut = provider.isCheckedIn;

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: isClockingOut ? 'Clock Out' : 'Clock In',
      message: isClockingOut
          ? 'Are you sure you want to clock out for today?'
          : 'Are you sure you want to clock in now?',
      confirmText: isClockingOut ? 'Clock Out' : 'Clock In',
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final bool success;
    if (isClockingOut) {
      success = await provider.checkOut();
    } else {
      success = await provider.checkIn();
    }

    if (!context.mounted) return;

    if (success) {
      AppToast.showSuccess(
        context,
        isClockingOut
            ? 'Clocked out successfully!'
            : 'Clocked in successfully!',
      );
    } else {
      AppDialog.showError(
        context: context,
        title: 'Action Failed',
        message: provider.errorMessage ?? 'Unable to record attendance.',
      );
    }
  }

  String _formatTimeWithSeconds(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatHourMinute(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildStatusPill(
    BuildContext context,
    AttendanceProvider attendance,
    bool isDark,
  ) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData icon;
    final String label;

    if (attendance.isCheckedOut) {
      bgColor = isDark ? const Color(0xFF063C2E) : const Color(0xFFECFDF5);
      borderColor = isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);
      textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
      label = context.tr('shift_completed');
    } else if (attendance.isCheckedIn) {
      bgColor = isDark ? const Color(0xFF3B1E08) : const Color(0xFFFFFBEB);
      borderColor = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
      textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      icon = Icons.radio_button_checked_rounded;
      label = context.tr('currently_clocked_in');
    } else {
      bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      textColor = isDark
          ? AppColors.darkTextSecondary
          : AppColors.textSecondary;
      icon = Icons.schedule_rounded;
      label = context.tr('ready_to_record');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, $monthName ${dt.day}, ${dt.year}';
  }
}

class _MiniTimeBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _MiniTimeBlock({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
