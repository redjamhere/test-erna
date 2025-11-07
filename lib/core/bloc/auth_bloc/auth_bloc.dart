import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_erna/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AuthEvent>(_onAuthEvent);
  }

  /// Main event handler using freezed's when method
  Future<void> _onAuthEvent(AuthEvent event, Emitter<AuthState> emit) async {
    await event.when(
      checkAuthStatus: () => _handleCheckAuthStatus(emit),
      loginWithEmailPassword: (email, password) =>
          _handleLoginWithEmailPassword(email, password, emit),
      register: (email, password, name) =>
          _handleRegister(email, password, name, emit),
      logout: () => _handleLogout(emit),
      refreshToken: () => _handleRefreshToken(emit),
    );
  }

  /// Check if user is authenticated
  Future<void> _handleCheckAuthStatus(Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.loading());

      final hasValidSession = await _authRepository.hasValidSession();

      if (hasValidSession) {
        final userId = await _authRepository.getCurrentUserId();
        final email = await _authRepository.getCurrentUserEmail();

        if (userId != null && email != null) {
          emit(AuthState.authenticated(userId: userId, email: email));
        } else {
          emit(const AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  /// Login with email and password
  Future<void> _handleLoginWithEmailPassword(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.loading());

      final success = await _authRepository.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (success) {
        await _emitAuthenticatedState(emit);
      } else {
        emit(const AuthState.error(message: 'Неверная почта или пароль'));
      }
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  /// Register new user
  Future<void> _handleRegister(
    String email,
    String password,
    String name,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.loading());

      final success = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );

      if (success) {
        await _emitAuthenticatedState(emit);
      } else {
        emit(
          const AuthState.error(
            message: 'Ошибка регистрации. Попробуйте снова.',
          ),
        );
      }
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  /// Logout user
  Future<void> _handleLogout(Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.loading());
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  /// Refresh authentication token
  Future<void> _handleRefreshToken(Emitter<AuthState> emit) async {
    try {
      final newToken = await _authRepository.refreshAccessToken();

      if (newToken != null) {
        // Token refreshed successfully, maintain authenticated state
        await _emitAuthenticatedState(emit);
      } else {
        // Token refresh failed, logout user
        await _authRepository.logout();
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      // On error, logout user
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    }
  }

  /// Helper method to emit authenticated state with user data
  Future<void> _emitAuthenticatedState(Emitter<AuthState> emit) async {
    final userId = await _authRepository.getCurrentUserId();
    final email = await _authRepository.getCurrentUserEmail();

    if (userId != null && email != null) {
      emit(AuthState.authenticated(userId: userId, email: email));
    } else {
      emit(
        const AuthState.error(
          message: 'Не удалось получить информацию о пользователе',
        ),
      );
    }
  }
}
