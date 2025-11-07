part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.emailChanged(String email) = _EmailChanged;
  const factory LoginEvent.passwordChanged(String password) = _PasswordChanged;
  const factory LoginEvent.togglePasswordVisibility() =
      _TogglePasswordVisibility;
  const factory LoginEvent.submit() = _Submit;
  const factory LoginEvent.clearError() = _ClearError;
}
