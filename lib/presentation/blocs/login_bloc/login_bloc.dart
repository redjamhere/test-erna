import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState.initial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<LoginState> emit) async {
    await event.when(
      emailChanged: (email) async => _handleEmailChanged(email, emit),
      passwordChanged: (password) async =>
          _handlePasswordChanged(password, emit),
      togglePasswordVisibility: () async =>
          _handleTogglePasswordVisibility(emit),
      submit: () async => await _handleSubmit(emit),
      clearError: () async => _handleClearError(emit),
    );
  }

  void _handleEmailChanged(String email, Emitter<LoginState> emit) {
    // Get current values from state, or use defaults if initial
    final currentPassword = state.maybeMap(
      form: (s) => s.password,
      loading: (s) => s.password,
      error: (s) => s.password,
      orElse: () => '',
    );

    final currentPasswordError = state.maybeMap(
      form: (s) => s.passwordError,
      orElse: () => null,
    );

    final currentIsPasswordVisible = state.maybeMap(
      form: (s) => s.isPasswordVisible,
      orElse: () => false,
    );

    final emailError = _validateEmail(email);

    emit(
      LoginState.form(
        email: email,
        password: currentPassword,
        emailError: emailError,
        passwordError: currentPasswordError,
        isPasswordVisible: currentIsPasswordVisible,
        isValid: emailError == null && currentPasswordError == null,
      ),
    );
  }

  void _handlePasswordChanged(String password, Emitter<LoginState> emit) {
    // Get current values from state, or use defaults if initial
    final currentEmail = state.maybeMap(
      form: (s) => s.email,
      loading: (s) => s.email,
      error: (s) => s.email,
      orElse: () => '',
    );

    final currentEmailError = state.maybeMap(
      form: (s) => s.emailError,
      orElse: () => null,
    );

    final currentIsPasswordVisible = state.maybeMap(
      form: (s) => s.isPasswordVisible,
      orElse: () => false,
    );

    final passwordError = _validatePassword(password);

    emit(
      LoginState.form(
        email: currentEmail,
        password: password,
        emailError: currentEmailError,
        passwordError: passwordError,
        isPasswordVisible: currentIsPasswordVisible,
        isValid: currentEmailError == null && passwordError == null,
      ),
    );
  }

  void _handleTogglePasswordVisibility(Emitter<LoginState> emit) {
    // Only toggle if we're in form state
    state.maybeMap(
      form: (currentState) {
        emit(
          LoginState.form(
            email: currentState.email,
            password: currentState.password,
            emailError: currentState.emailError,
            passwordError: currentState.passwordError,
            isPasswordVisible: !currentState.isPasswordVisible,
            isValid: currentState.isValid,
          ),
        );
      },
      orElse: () {
        // If not in form state, initialize with toggle on
        emit(
          const LoginState.form(
            email: '',
            password: '',
            emailError: null,
            passwordError: null,
            isPasswordVisible: true,
            isValid: false,
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(Emitter<LoginState> emit) async {
    // Get current email and password from state
    final currentEmail = state.maybeMap(
      form: (s) => s.email,
      loading: (s) => s.email,
      error: (s) => s.email,
      orElse: () => '',
    );

    final currentPassword = state.maybeMap(
      form: (s) => s.password,
      loading: (s) => s.password,
      error: (s) => s.password,
      orElse: () => '',
    );

    final currentIsPasswordVisible = state.maybeMap(
      form: (s) => s.isPasswordVisible,
      orElse: () => false,
    );

    // Validate all fields
    final emailError = _validateEmail(currentEmail);
    final passwordError = _validatePassword(currentPassword);

    if (emailError != null || passwordError != null) {
      emit(
        LoginState.form(
          email: currentEmail,
          password: currentPassword,
          emailError: emailError,
          passwordError: passwordError,
          isPasswordVisible: currentIsPasswordVisible,
          isValid: false,
        ),
      );
      return;
    }

    // Show loading
    emit(LoginState.loading(email: currentEmail, password: currentPassword));

    // Simulate API call (replace with actual authentication)
    await Future.delayed(const Duration(seconds: 2));

    // Mock validation - replace with actual logic
    if (currentEmail == 'error@test.com') {
      emit(
        LoginState.error(
          message: 'Invalid email or password',
          email: currentEmail,
          password: currentPassword,
        ),
      );
    } else {
      emit(
        LoginState.success(
          email: currentEmail,
          userId: 'user_123', // This would come from your auth response
        ),
      );
    }
  }

  void _handleClearError(Emitter<LoginState> emit) {
    final currentState = state;

    currentState.maybeWhen(
      error: (message, email, password) {
        emit(
          LoginState.form(
            email: email,
            password: password,
            emailError: null,
            passwordError: null,
            isPasswordVisible: false,
            isValid: email.isNotEmpty && password.isNotEmpty,
          ),
        );
      },
      orElse: () {},
    );
  }

  // Validation methods
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Электронная почта обязательна';
    }

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Пожалуйста, введите корректный адрес электронной почты';
    }

    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Пароль обязателен';
    }

    if (password.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }

    return null;
  }
}
