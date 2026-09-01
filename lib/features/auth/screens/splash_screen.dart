import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';

/// Shown briefly at app launch while we check for a stored token.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.initialize();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      AppRouter.navigateToAndRemoveUntil(context, AppRoutes.home);
    } else {
      AppRouter.navigateToAndRemoveUntil(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Attendance',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
