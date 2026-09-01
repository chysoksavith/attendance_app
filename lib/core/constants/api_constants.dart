import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URL — automatically resolves:
  // - Android emulator: 10.0.2.2 (maps to host's 127.0.0.1)
  // - Web / Linux desktop: 127.0.0.1
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

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
