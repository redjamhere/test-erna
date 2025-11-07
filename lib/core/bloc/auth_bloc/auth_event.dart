part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
  const factory AuthEvent.loginWithEmailPassword({
    required String email,
    required String password,
  }) = _LoginWithEmailPassword;
  const factory AuthEvent.register({
    required String email,
    required String password,
    required String name,
  }) = _Register;
  const factory AuthEvent.logout() = _Logout;
  const factory AuthEvent.refreshToken() = _RefreshToken;
}
