import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Auth state — drives the entire app's auth flow.
enum AuthStatus { initial, authenticated, unauthenticated, loading }

/// Centralized auth state manager.
///
/// Owns: login, OTP verification, token persistence, logout.
/// UI reads [status], [user], [error] and calls actions.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  AuthProvider({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  // -- State -----------------------------------------------------------------

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserModel? _user;
  UserModel? get user => _user;

  String? _error;
  String? get error => _error;

  Map<String, List<String>> _fieldErrors = {};
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  // OTP flow state
  String? _verificationToken;
  String? get verificationToken => _verificationToken;

  String? _maskedEmail;
  String? get maskedEmail => _maskedEmail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // -- Actions ---------------------------------------------------------------

  /// Check if user has a stored token and restore session.
  Future<void> initialize() async {
    final hasToken = await _tokenStorage.hasToken();

    if (!hasToken) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Try restoring user from cache
    final cachedUser = await _tokenStorage.getUserData();
    if (cachedUser != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(cachedUser) as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
        notifyListeners();
      } catch (_) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Login with email/phone + password.
  /// Returns `true` if login succeeded (tokens issued),
  /// `false` if OTP is required (navigate to OTP screen).
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.login(
        identifier: identifier,
        password: password,
      );

      switch (result) {
        case LoginResultSuccess(:final data):
          await _handleLoginSuccess(data);
          return true;

        case LoginResultOtpRequired(:final data):
          _verificationToken = data.verificationToken;
          _maskedEmail = data.maskedEmail;
          _setLoading(false);
          return false;
      }
    } on ApiException catch (e) {
      _setError(e.message, e.errors);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Verify OTP code.
  Future<bool> verifyOtp(String otp) async {
    if (_verificationToken == null) {
      _setError('Session expired. Please login again.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.verifyOtp(
        verificationToken: _verificationToken!,
        otp: otp,
      );

      await _handleLoginSuccess(result);
      _verificationToken = null;
      _maskedEmail = null;
      return true;
    } on ApiException catch (e) {
      _setError(e.message, e.errors);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Resend OTP code.
  Future<bool> resendOtp() async {
    if (_verificationToken == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final maskedEmail = await _repository.resendOtp(
        verificationToken: _verificationToken!,
      );
      _maskedEmail = maskedEmail;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Could not resend code. Please try again.');
      return false;
    }
  }

  /// Logout and clear local state.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Even if API call fails, clear local state
    }

    await _tokenStorage.clearAll();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _verificationToken = null;
    _maskedEmail = null;
    notifyListeners();
  }

  // -- Helpers ---------------------------------------------------------------

  Future<void> _handleLoginSuccess(LoginSuccess data) async {
    await _tokenStorage.saveTokens(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
    );
    await _tokenStorage.saveUserData(jsonEncode(data.user.toJson()));

    _user = data.user;
    _status = AuthStatus.authenticated;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message, [Map<String, List<String>>? fieldErrors]) {
    _error = message;
    _fieldErrors = fieldErrors ?? {};
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    _fieldErrors = {};
  }

  /// Clear error state (call when user starts typing again).
  void clearError() {
    _error = null;
    _fieldErrors = {};
    notifyListeners();
  }
}
