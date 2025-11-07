import 'package:local_auth/local_auth.dart';
import '../dao/local_auth_dao.dart';

abstract interface class LocalAuthRepository {
  Future<bool> isLoggedIn();
  Future<bool> isBiometricAvailable();
  Future<bool> isDeviceSupported();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> authenticateWithBiometrics({String localizedReason});
  Future<bool> authenticateWithDeviceCredentials({String localizedReason});
}

/// Repository for authentication operations
/// Handles both local and remote authentication
class LocalAuthRepositoryImpl implements LocalAuthRepository {
  final LocalAuthDao _localAuthDao;
  final LocalAuthentication _localAuth;

  LocalAuthRepositoryImpl(this._localAuthDao, this._localAuth);

  // ============ Local Storage Operations ============

  /// Check if user is logged in
  @override
  Future<bool> isLoggedIn() async {
    return await _localAuthDao.isLoggedIn();
  }

  // ============ Biometric Authentication ============

  /// Check if biometric authentication is available on device
  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if device has biometric hardware
  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if biometric is enabled in app settings
  @override
  Future<bool> isBiometricEnabled() async {
    return await _localAuthDao.isBiometricEnabled();
  }

  /// Enable/disable biometric authentication
  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _localAuthDao.setBiometricEnabled(enabled);
  }

  /// Authenticate with biometrics
  @override
  Future<bool> authenticateWithBiometrics({
    String localizedReason =
        'Пожалуйста, подтвердите свою личность для доступа к данным о здоровье',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true, // Only biometric, no PIN/password fallback
      );
    } catch (e) {
      return false;
    }
  }

  /// Authenticate with biometrics or device credentials (PIN, pattern, password)
  @override
  Future<bool> authenticateWithDeviceCredentials({
    String localizedReason =
        'Пожалуйста, подтвердите свою личность для доступа к данным о здоровье',
  }) async {
    try {
      return await _localAuth.authenticate(localizedReason: localizedReason);
    } catch (e) {
      return false;
    }
  }

  // ============ PIN Code Authentication ============

  /// Save PIN code
  Future<void> savePinCode(String pin) async {
    // In production, hash the PIN before storing
    final hashedPin = _hashPin(pin);
    await _localAuthDao.savePinCode(hashedPin);
  }

  /// Verify PIN code
  Future<bool> verifyPinCode(String pin) async {
    final storedHash = await _localAuthDao.getPinCode();
    if (storedHash == null) {
      return false;
    }
    final hashedPin = _hashPin(pin);
    return hashedPin == storedHash;
  }

  /// Check if PIN is set
  Future<bool> hasPinCode() async {
    final pin = await _localAuthDao.getPinCode();
    return pin != null && pin.isNotEmpty;
  }

  /// Remove PIN code
  Future<void> removePinCode() async {
    await _localAuthDao.savePinCode('');
  }

  // ============ Login/Register Operations ============
  // These would typically call your backend API

  // ============ Helper Methods ============

  /// Simple hash function for PIN (use proper hashing in production)
  String _hashPin(String pin) {
    // In production, use a proper hashing algorithm like bcrypt or argon2
    // This is just a placeholder
    return pin.split('').map((c) => c.codeUnitAt(0)).join('-');
  }
}
