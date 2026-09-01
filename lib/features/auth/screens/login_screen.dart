import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Branding
                  const _AppBranding(),
                  const SizedBox(height: 40),

                  // Login form
                  LoginForm(
                    onLoginSuccess: () {
                      AppRouter.navigateToAndRemoveUntil(
                        context,
                        AppRoutes.home,
                      );
                    },
                    onOtpRequired: () {
                      AppRouter.navigateTo(context, AppRoutes.otpVerify);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBranding extends StatelessWidget {
  const _AppBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App icon
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
        const SizedBox(height: 6),
        Text(
          'Sign in to continue',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
