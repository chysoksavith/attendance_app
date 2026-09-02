import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              // Avatar + info
              UserAvatar(user: user, radius: 40, fontSize: 26),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'User',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),

              // Menu group 1: Account info
              _MenuGroup(
                children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: context.tr('personal_info'),
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.work_outline_rounded,
                    label: context.tr('employment'),
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    label: context.tr('attendance_history'),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Menu group 2: Preferences (Language & Appearance)
              _MenuGroup(
                children: [
                  _MenuItem(
                    icon: Icons.language_rounded,
                    label: context.tr('language'),
                    trailing: settings.languageName,
                    onTap: () => _showLanguageSheet(context, settings),
                  ),
                  _MenuItem(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    label: context.tr('appearance'),
                    trailing: settings.themeModeName,
                    onTap: () => _showAppearanceSheet(context, settings),
                  ),
                ],
              ),

              if (user != null && user.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                _MenuGroup(
                  children: [
                    for (final attachment in user.attachments)
                      _MenuItem(
                        icon: Icons.attach_file_rounded,
                        label: attachment.fileName,
                        trailing: attachment.size != null
                            ? '${(attachment.size! / 1024).toStringAsFixed(1)} KB'
                            : 'Unknown size',
                        onTap: () {},
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              // Sign out
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _handleLogout(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.error.withAlpha(50)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('sign_out'),
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceSheet(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('select_appearance'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _SelectionTile(
                  icon: Icons.light_mode_outlined,
                  title: context.tr('theme_light'),
                  isSelected: settings.themeMode == ThemeMode.light,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                _SelectionTile(
                  icon: Icons.dark_mode_outlined,
                  title: context.tr('theme_dark'),
                  isSelected: settings.themeMode == ThemeMode.dark,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                _SelectionTile(
                  icon: Icons.brightness_auto_outlined,
                  title: context.tr('theme_system'),
                  isSelected: settings.themeMode == ThemeMode.system,
                  onTap: () {
                    settings.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('select_language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _SelectionTile(
                  icon: Icons.language_rounded,
                  title: 'English (US)',
                  isSelected: settings.locale.languageCode == 'en',
                  onTap: () {
                    settings.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                _SelectionTile(
                  icon: Icons.language_rounded,
                  title: 'ភាសាខ្មែរ (Khmer)',
                  isSelected: settings.locale.languageCode == 'km',
                  onTap: () {
                    settings.setLocale(const Locale('km'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: context.tr('sign_out'),
      message: context.tr('sign_out_confirm'),
      confirmText: context.tr('sign_out'),
      isDangerous: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;
    AppRouter.navigateToAndRemoveUntil(context, AppRoutes.login);
  }
}

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withAlpha(80),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 52,
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.border.withAlpha(80),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
