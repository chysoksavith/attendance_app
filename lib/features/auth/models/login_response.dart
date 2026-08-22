import 'user_model.dart';

/// Immediate login success (OTP disabled for the company).
class LoginSuccess {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const LoginSuccess({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginSuccess.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginSuccess(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }
}

/// OTP required — backend sent a verification code.
class LoginOtpRequired {
  final String verificationToken;
  final String maskedEmail;

  const LoginOtpRequired({
    required this.verificationToken,
    required this.maskedEmail,
  });

  factory LoginOtpRequired.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginOtpRequired(
      verificationToken: data['verification_token'] as String,
      maskedEmail: data['masked_email'] as String,
    );
  }
}

/// Union type for the login endpoint's two possible success results.
sealed class LoginResult {}

class LoginResultSuccess extends LoginResult {
  final LoginSuccess data;
  LoginResultSuccess(this.data);
}

class LoginResultOtpRequired extends LoginResult {
  final LoginOtpRequired data;
  LoginResultOtpRequired(this.data);
}
