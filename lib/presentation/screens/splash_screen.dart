import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_erna/core/bloc/auth_bloc/auth_bloc.dart';
import 'package:test_erna/core/composition_root.dart';
import 'package:test_erna/core/router/app_router.gr.dart';
import 'package:test_erna/data/repositories/local_auth_repository.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Check authentication status
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Trigger auth check
    context.read<AuthBloc>().add(const AuthEvent.checkAuthStatus());
  }

  Future<void> _handleAuthenticated(String userId, String email) async {
    final localAuthRepo = CompositionRoot.get<LocalAuthRepository>();

    // Check if biometric is available and enabled
    final canUseBiometric = await localAuthRepo.isBiometricAvailable();

    if (canUseBiometric) {
      final isBiometricEnabled = await localAuthRepo.isBiometricEnabled();

      if (isBiometricEnabled) {
        // Show biometric authentication
        await _authenticateWithBiometric(localAuthRepo);
      } else {
        // Biometric available but not enabled, go to main screen
        _navigateToMain();
      }
    } else {
      // Biometric not available, go to main screen
      _navigateToMain();
    }
  }

  Future<void> _authenticateWithBiometric(
    LocalAuthRepository localAuthRepo,
  ) async {
    try {
      final authenticated = await localAuthRepo.authenticateWithBiometrics(
        localizedReason:
            'Пожалуйста, подтвердите свою личность для доступа к данным о здоровье',
      );

      if (authenticated) {
        _navigateToMain();
      } else {
        // Biometric authentication failed
        _showBiometricFailedDialog();
      }
    } catch (e) {
      // Error during biometric authentication
      _showBiometricErrorDialog(e.toString());
    }
  }

  void _showBiometricFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка аутентификации'),
        content: const Text(
          'Биометрическая аутентификация не удалась. Пожалуйста, попробуйте снова или выйдите из системы.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Выйти'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final localAuthRepo = CompositionRoot.get<LocalAuthRepository>();
              await _authenticateWithBiometric(localAuthRepo);
            },
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  void _showBiometricErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text('Произошла ошибка при аутентификации: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Выйти'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToMain();
            },
            child: const Text('Продолжить без биометрии'),
          ),
        ],
      ),
    );
  }

  void _navigateToMain() {
    if (mounted) {
      context.router.replace(const MainRoute());
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      // Logout user first
      context.read<AuthBloc>().add(const AuthEvent.logout());
      context.router.replace(const LoginRoute());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {
            // Still checking, do nothing
          },
          loading: () {
            // Loading, do nothing
          },
          authenticated: (userId, email) async {
            // User is authenticated, check biometric
            await _handleAuthenticated(userId, email);
          },
          unauthenticated: () {
            // User is not authenticated, go to login
            _navigateToLogin();
          },
          error: (message) {
            // Error occurred, show message and go to login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
            Future.delayed(const Duration(seconds: 2), _navigateToLogin);
          },
        );
      },
      child: Scaffold(
        backgroundColor: isDark
            ? theme.colorScheme.background
            : theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Logo/Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: .1,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.watch,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App Name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'ЭРНА',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Мониторинг здоровья',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .1),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Loading Indicator
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => Column(
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Проверка авторизации...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      authenticated: (_, __) => Column(
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Верификация биометрии...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      orElse: () => FadeTransition(
                        opacity: _fadeAnimation,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
