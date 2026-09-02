import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Secure token storage using Flutter Secure Storage (Keychain / Keystore).
class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  // -- Access Token ----------------------------------------------------------

  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  // -- Refresh Token ---------------------------------------------------------

  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  // -- Tokens pair -----------------------------------------------------------

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // -- User Data (JSON string) -----------------------------------------------

  Future<String?> getUserData() async {
    return _storage.read(key: StorageKeys.userData);
  }

  Future<void> saveUserData(String jsonString) async {
    await _storage.write(key: StorageKeys.userData, value: jsonString);
  }

  // -- Theme & Language Preferences -----------------------------------------

  Future<String?> getThemeMode() async {
    return _storage.read(key: StorageKeys.themeMode);
  }

  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: StorageKeys.themeMode, value: mode);
  }

  Future<String?> getLanguageCode() async {
    return _storage.read(key: StorageKeys.languageCode);
  }

  Future<void> saveLanguageCode(String lang) async {
    await _storage.write(key: StorageKeys.languageCode, value: lang);
  }

  // -- Clear -----------------------------------------------------------------

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
