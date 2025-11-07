import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Data Access Object for local authentication
/// Handles secure storage operations for user credentials and auth tokens
class LocalAuthDao {
  final FlutterSecureStorage _secureStorage;

  LocalAuthDao(this._secureStorage);

  // Storage keys

  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPinCode = 'pin_code';
  static const String _keyIsLoggedIn = 'is_logged_in';

  /// Save biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Get biometric enabled status
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// Save PIN code (hashed)
  Future<void> savePinCode(String hashedPin) async {
    await _secureStorage.write(key: _keyPinCode, value: hashedPin);
  }

  /// Get PIN code (hashed)
  Future<String?> getPinCode() async {
    return await _secureStorage.read(key: _keyPinCode);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await _secureStorage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
