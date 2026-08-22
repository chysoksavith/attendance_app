import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onOtpRequired;

  const LoginForm({
    super.key,
    required this.onLoginSuccess,
    required this.onOtpRequired,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      widget.onLoginSuccess();
    } else if (auth.verificationToken != null) {
      // OTP required — navigate to OTP screen
      widget.onOtpRequired();
    }
    // If neither, error is shown via the provider state
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error banner
              if (auth.error != null && !auth.hasValidationFieldErrors) ...[
                _ErrorBanner(message: auth.error!),
                const SizedBox(height: 16),
              ],

              // Identifier field (email or phone)
              AppTextField(
                label: 'Email or Phone',
                hint: 'Enter your email or phone number',
                icon: Icons.person_outline_rounded,
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email or phone number';
                  }
                  return null;
                },
                onChanged: (_) {
                  if (auth.error != null) auth.clearError();
                },
              ),

              const SizedBox(height: 16),

              // Password field
              AppTextField(
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (_) {
                  if (auth.error != null) auth.clearError();
                },
              ),

              const SizedBox(height: 28),

              // Login button
              AppButton(
                label: 'Sign In',
                isLoading: auth.isLoading,
                onPressed: auth.isLoading ? null : _handleLogin,
                height: 52,
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on AuthProvider {
  bool get hasValidationFieldErrors => fieldErrors.isNotEmpty;
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
