import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../models/leave_balance_model.dart';
import '../providers/leave_provider.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveProvider>().fetchBalances();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<LeaveProvider>().refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('leave'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('manage_leave_requests'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Dynamic Balance Cards
                Consumer<LeaveProvider>(
                  builder: (context, provider, _) {
                    return _buildBalanceSection(context, provider, isDark);
                  },
                ),

                const SizedBox(height: 28),

                Text(
                  context.tr('recent_requests'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 40,
                        color: AppColors.textMuted.withAlpha(120),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('no_leave_requests'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildBalanceSection(
    BuildContext context,
    LeaveProvider provider,
    bool isDark,
  ) {
    if (provider.state == LeaveViewState.loading && provider.balances.isEmpty) {
      return Container(
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withAlpha(80),
          ),
        ),
        child: const AppLoading(size: 28),
      );
    }

    if (provider.state == LeaveViewState.error && provider.balances.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withAlpha(100)),
        ),
        child: Column(
          children: [
            Text(
              provider.errorMessage ?? 'Failed to load leave balances',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: context.tr('retry'),
              height: 36,
              onPressed: () => provider.fetchBalances(),
            ),
          ],
        ),
      );
    }

    if (provider.balances.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withAlpha(80),
          ),
        ),
        child: Text(
          context.tr('no_leave_balances'),
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      );
    }

    final balances = provider.balances;

    if (balances.length <= 3) {
      return Row(
        children: balances.asMap().entries.map((entry) {
          final index = entry.key;
          final balance = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < balances.length - 1 ? 12.0 : 0.0,
              ),
              child: _BalanceCard(balance: balance, isDark: isDark),
            ),
          );
        }).toList(),
      );
    }

    // Horizontal scrollable cards for 4+ leave types
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: balances.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 110,
          child: _BalanceCard(balance: balances[index], isDark: isDark),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final LeaveBalanceModel balance;
  final bool isDark;

  const _BalanceCard({required this.balance, required this.isDark});

  Color _getAccentColor(String slug) {
    final s = slug.toLowerCase();
    if (s.contains('annual')) return AppColors.primary;
    if (s.contains('sick')) return const Color(0xFFD97706);
    if (s.contains('personal')) return const Color(0xFF0D9488);
    if (s.contains('maternity') || s.contains('paternity')) {
      return const Color(0xFFEC4899);
    }
    if (s.contains('unpaid')) return const Color(0xFF6B7280);
    return const Color(0xFF6366F1);
  }

  String _getLabel(BuildContext context) {
    final slug = balance.leaveType?.slug.toLowerCase() ?? '';
    if (slug.contains('annual')) return context.tr('annual_leave');
    if (slug.contains('sick')) return context.tr('sick_leave');
    if (slug.contains('personal')) return context.tr('personal_leave');
    return balance.leaveTypeName;
  }

  @override
  Widget build(BuildContext context) {
    final slug = balance.leaveType?.slug ?? '';
    final accentColor = _getAccentColor(slug);
    final label = _getLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withAlpha(80),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            balance.formattedRemainingDays,
            style: TextStyle(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
