class ApiConstants {
  // Base URL:
  // - Defaults to http://127.0.0.1:8000 (works directly on physical devices via `adb reverse tcp:8000 tcp:8000`, Desktop & Web)
  // - Can be overridden at build/run time via: --dart-define=API_URL=http://your-ip:8000
  static String get baseUrl {
    const String configuredUrl = String.fromEnvironment('API_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }
    return 'http://127.0.0.1:8000';
  }

  static const String apiPrefix = '/api/v1';

  // Health check endpoint
  static const String health = '$apiPrefix/health';

  // Auth endpoints
  static const String login = '$apiPrefix/login';
  static const String verifyOtp = '$apiPrefix/verify-otp';
  static const String resendOtp = '$apiPrefix/resend-otp';
  static const String user = '$apiPrefix/user';
  static const String refreshToken = '$apiPrefix/refresh-token';
  static const String logout = '$apiPrefix/logout';
  static const String logoutAll = '$apiPrefix/logout-all';

  // Domain endpoints
  static const String holidays = '$apiPrefix/holidays';
  static const String companyLocations = '$apiPrefix/company-locations';
  static const String shifts = '$apiPrefix/shifts';

  // Leave endpoints
  static const String leaveBalances = '$apiPrefix/leave/balances';

  // Attendance endpoints
  static const String attendances = '$apiPrefix/attendances';
  static const String attendanceSettings = '$apiPrefix/attendances/settings';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Prevent instantiation
  ApiConstants._();
}
