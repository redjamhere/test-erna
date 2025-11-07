part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;

  const factory LoginState.form({
    required String email,
    required String password,
    String? emailError,
    String? passwordError,
    required bool isPasswordVisible,
    required bool isValid,
  }) = _Form;

  const factory LoginState.loading({
    required String email,
    required String password,
  }) = _Loading;

  const factory LoginState.success({
    required String email,
    required String userId,
  }) = _Success;

  const factory LoginState.error({
    required String message,
    required String email,
    required String password,
  }) = _Error;
}
