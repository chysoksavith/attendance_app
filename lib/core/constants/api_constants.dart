class ApiConstants {
  // Base URL — change per environment
  // Android emulator: use 10.0.2.2 (maps to host's 127.0.0.1)
  // Chrome/Linux desktop: use 127.0.0.1 directly
  // Physical device: use your machine's LAN IP
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiPrefix = '/api/v1';

  // Auth endpoints
  static const String login = '$apiPrefix/login';
  static const String verifyOtp = '$apiPrefix/verify-otp';
  static const String resendOtp = '$apiPrefix/resend-otp';
  static const String user = '$apiPrefix/user';
  static const String refreshToken = '$apiPrefix/refresh-token';
  static const String logout = '$apiPrefix/logout';
  static const String logoutAll = '$apiPrefix/logout-all';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Prevent instantiation
  ApiConstants._();
}
