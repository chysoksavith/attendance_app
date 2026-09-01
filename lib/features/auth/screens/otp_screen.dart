import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_input.dart';

import '../../../core/widgets/app_toast.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _canResend = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => _resendCountdown--);

      if (_resendCountdown <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      AppToast.show(context, 'Please enter the 6-digit code', isError: true);
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      AppToast.show(context, 'Signed in successfully');
      AppRouter.navigateToAndRemoveUntil(context, AppRoutes.home);
    } else {
      if (auth.error != null) {
        AppToast.show(context, auth.error!, isError: true);
      }
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    final auth = context.read<AuthProvider>();
    final sent = await auth.resendOtp();

    if (!mounted) return;

    if (sent) {
      _startResendTimer();
      AppToast.show(context, 'A new code has been sent');
    } else {
      if (auth.error != null) {
        AppToast.show(context, auth.error!, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            context.read<AuthProvider>().clearError();
            AppRouter.goBack(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Verify Your Identity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification code to',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.maskedEmail ?? '***@***.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OTP Input
                  OtpInput(
                    controller: _otpController,
                    onCompleted: (_) => _handleVerify(),
                    onChanged: (_) {
                      if (auth.error != null) auth.clearError();
                    },
                  ),

                  const SizedBox(height: 28),

                  // Verify button
                  AppButton(
                    label: 'Verify',
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _handleVerify,
                    height: 52,
                  ),

                  const SizedBox(height: 20),

                  // Resend link
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _handleResend,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            'Resend code in ${_resendCountdown}s',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
