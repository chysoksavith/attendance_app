import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../attendance/widgets/attendance_history_card.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final attendance = context.watch<AttendanceProvider>();
    final today = attendance.todayAttendance;

    final inTime = today?.checkIn.at != null
        ? _formatTime(today!.checkIn.at!)
        : '--';
    final outTime = today?.checkOut.at != null
        ? _formatTime(today!.checkOut.at!)
        : '--';

    final now = DateTime.now();
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
                // Top App Bar / Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date & Welcome Greeting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatHeaderDate(now),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${context.tr('welcome')}, ${user?.name ?? 'User'}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),

                    // Notification Icon + User Avatar
                    Row(
                      children: [
                        // Notification Bell with unread indicator
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border.withAlpha(80),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              top: 11,
                              right: 12,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Avatar
                        UserAvatar(user: user, radius: 22),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Large Main Headline: "Today's Summary"
                Text(
                  context.tr('todays_summary').replaceAll(' ', '\n'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Today's Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
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
                        color: Colors.black.withAlpha(isDark ? 30 : 6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Clock In Block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('clock_in'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              inTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Clock Out Block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('clock_out'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              outTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Button (Clock In Now / Clock Out Now / Completed)
                      GestureDetector(
                        onTap: attendance.isClocking || attendance.isCheckedOut
                            ? null
                            : () => _handleClockAction(context, attendance),
                        child: _buildHomeClockActionButton(
                          context,
                          attendance,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Request Status Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('request_status'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      context.tr('see_all'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 3 Stat Cards (Request, Approved, Decline)
                Row(
                  children: [
                    _RequestStatCard(
                      count: '25',
                      label: context.tr('request'),
                      accentColor: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _RequestStatCard(
                      count: '8',
                      label: context.tr('approved'),
                      accentColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 12),
                    _RequestStatCard(
                      count: '16',
                      label: context.tr('decline'),
                      accentColor: const Color(0xFFEF4444),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Recent Activity Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('recent_activity'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (attendance.history.isNotEmpty)
                      Text(
                        context.tr('view_all'),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Activity List / Empty State
                if (attendance.history.isNotEmpty)
                  ...attendance.history
                      .take(3)
                      .map((item) => AttendanceHistoryCard(attendance: item))
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          size: 36,
                          color: AppColors.textMuted.withAlpha(120),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('no_activity'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _isProcessingHomeAction = false;

  Future<void> _handleClockAction(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    if (_isProcessingHomeAction || provider.isClocking) return;

    // Guard: Prevent double-click / accidental clock-out during cooldown
    if (provider.isCheckedIn && provider.isClockLocked) {
      AppToast.showWarning(
        context,
        context.tr('cooldown_warning', {
          'seconds': '${provider.lockRemainingSeconds}',
        }),
      );
      return;
    }

    _isProcessingHomeAction = true;
    try {
      final isClockingOut = provider.isCheckedIn;

      final confirmed = await AppDialog.showConfirmation(
        context: context,
        title: isClockingOut ? context.tr('clock_out') : context.tr('clock_in'),
        message: isClockingOut
            ? context.tr('confirm_clock_out')
            : context.tr('confirm_clock_in'),
        confirmText: isClockingOut
            ? context.tr('clock_out')
            : context.tr('clock_in'),
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
          isClockingOut ? context.tr('clocked_out') : context.tr('clocked_in'),
        );
      } else {
        AppDialog.showError(
          context: context,
          title: context.tr('request_status'),
          message: provider.errorMessage ?? 'Unable to record attendance.',
        );
      }
    } finally {
      _isProcessingHomeAction = false;
    }
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatHeaderDate(DateTime dt) {
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
    return '$dayName, ${dt.day} $monthName';
  }

  Widget _buildHomeClockActionButton(
    BuildContext context,
    AttendanceProvider attendance,
    bool isDark,
  ) {
    if (attendance.isClocking) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (attendance.isCheckedOut) {
      final emeraldBg = isDark
          ? const Color(0xFF063C2E)
          : const Color(0xFFECFDF5);
      final emeraldBorder = isDark
          ? const Color(0xFF065F46)
          : const Color(0xFFA7F3D0);
      final emeraldText = isDark
          ? const Color(0xFF34D399)
          : const Color(0xFF059669);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: emeraldBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: emeraldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: emeraldText),
            const SizedBox(width: 6),
            Text(
              context.tr('completed'),
              style: TextStyle(
                color: emeraldText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (attendance.isCheckedIn) {
      if (attendance.isClockLocked) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF78350F) : const Color(0xFFD97706),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('wait_seconds', {
                  'seconds': '${attendance.lockRemainingSeconds}',
                }),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFEA580C),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              context.tr('clock_out_now'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            context.tr('clock_in_now'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestStatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color accentColor;

  const _RequestStatCard({
    required this.count,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withAlpha(80),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 4),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
