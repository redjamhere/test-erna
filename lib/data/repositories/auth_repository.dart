import 'package:test_erna/data/dao/auth_dao.dart';

abstract interface class AuthRepository {
  Future<bool> hasValidSession();
  Future<String?> getCurrentUserId();
  Future<String?> getCurrentUserEmail();
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
  });
  Future<void> logout();
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  });
  Future<String?> refreshAccessToken();
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDao _authDao;
  AuthRepositoryImpl(this._authDao);

  /// Check if user has valid session
  @override
  Future<bool> hasValidSession() async {
    return await _authDao.hasValidSession();
  }

  /// Get current user ID
  @override
  Future<String?> getCurrentUserId() async {
    return await _authDao.getUserId();
  }

  /// Get current user email
  @override
  Future<String?> getCurrentUserEmail() async {
    return await _authDao.getUserEmail();
  }

  /// Save authentication tokens
  @override
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    await _authDao.saveAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
    );
  }

  /// Logout user
  @override
  Future<void> logout() async {
    await _authDao.clearAuthData();
  }

  /// Register new user
  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // TODO: Call your backend API here
      // For now, this is a mock implementation

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      await _authDao.saveAuthSession(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'user_123',
        email: email,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh access token
  @override
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _authDao.getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      // TODO: Call your backend API to refresh token
      // For now, return mock token
      const newAccessToken = 'mock_refreshed_access_token';
      await _authDao.saveAccessToken(newAccessToken);

      return newAccessToken;
    } catch (e) {
      return null;
    }
  }

  /// Login with email and password
  @override
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Call your backend API here
      // For now, this is a mock implementation

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      await _authDao.saveAuthSession(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        userId: 'user_123',
        email: email,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
