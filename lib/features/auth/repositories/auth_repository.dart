import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

/// Handles all auth-related API calls. No business logic — just
/// request → response translation.
class AuthRepository {
  final ApiClient _client;

  AuthRepository({required ApiClient client}) : _client = client;

  /// Sends credentials. Returns either tokens (OTP disabled) or
  /// a verification token (OTP required).
  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      body: {'email': identifier, 'password': password},
    );

    final data = response['data'] as Map<String, dynamic>;

    if (data['requires_otp'] == true) {
      return LoginResultOtpRequired(LoginOtpRequired.fromJson(response));
    }

    return LoginResultSuccess(LoginSuccess.fromJson(response));
  }

  /// Verify OTP code with the verification token from login.
  Future<LoginSuccess> verifyOtp({
    required String verificationToken,
    required String otp,
  }) async {
    final response = await _client.post(
      ApiConstants.verifyOtp,
      body: {
        'verification_token': verificationToken,
        'otp': otp,
      },
    );

    return LoginSuccess.fromJson(response);
  }

  /// Resend OTP to the user's email.
  Future<String> resendOtp({required String verificationToken}) async {
    final response = await _client.post(
      ApiConstants.resendOtp,
      body: {'verification_token': verificationToken},
    );

    final data = response['data'] as Map<String, dynamic>;
    return data['masked_email'] as String? ?? '';
  }

  /// Fetch current authenticated user.
  Future<UserModel> getUser() async {
    final response = await _client.get(ApiConstants.user);
    final data = response['data'] as Map<String, dynamic>;
    final userData = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// Logout (revoke current token).
  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
  }

  /// Refresh the token pair.
  Future<LoginSuccess> refreshToken() async {
    final response = await _client.post(ApiConstants.refreshToken);
    return LoginSuccess.fromJson(response);
  }
}
