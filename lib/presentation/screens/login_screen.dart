import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_erna/core/bloc/auth_bloc/auth_bloc.dart';
import 'package:test_erna/core/composition_root.dart';
import 'package:test_erna/core/router/app_router.gr.dart';
import 'package:test_erna/data/repositories/local_auth_repository.dart';
import 'package:test_erna/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:test_erna/presentation/widgets/biometric_setup_dialog.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // // Initialize form state
    // context.read<LoginBloc>().add(const LoginEvent.emailChanged(''));
    // context.read<LoginBloc>().add(const LoginEvent.passwordChanged(''));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Unfocus text fields
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    // Submit login
    context.read<LoginBloc>().add(const LoginEvent.submit());
  }

  Future<void> _showBiometricSetupDialog(
    BuildContext context,
    LocalAuthRepository localAuthRepo,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BiometricSetupDialog(
        onEnableBiometric: () async {
          Navigator.of(dialogContext).pop();

          // Enable biometric
          await localAuthRepo.setBiometricEnabled(true);

          // Show success message
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Биометрия включена'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to main screen
          if (!context.mounted) return;
          context.router.replace(const MainRoute());
        },
        onSkip: () {
          Navigator.of(dialogContext).pop();

          // Navigate to main screen without enabling biometric
          if (!context.mounted) return;
          context.router.replace(const MainRoute());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (email, userId) async {
            // Trigger actual authentication
            context.read<AuthBloc>().add(
              AuthEvent.loginWithEmailPassword(
                email: email,
                password: _passwordController.text,
              ),
            );

            // Check if biometric is available
            final localAuthRepo = CompositionRoot.get<LocalAuthRepository>();
            final canUseBiometric = await localAuthRepo.isBiometricAvailable();
            final isBiometricEnabled = await localAuthRepo.isBiometricEnabled();

            if (!mounted) return;

            if (canUseBiometric && !isBiometricEnabled) {
              // Show biometric setup dialog
              await _showBiometricSetupDialog(context, localAuthRepo);
            } else {
              // Navigate to main screen
              if (!mounted) return;
              context.router.replace(const MainRoute());
            }
          },
          error: (message, _, __) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Закрыть',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 3),
                    ),
                    child: Icon(
                      Icons.watch,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),

                  // Welcome Text
                  Text(
                    'Добро пожаловать',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Войдите, чтобы продолжить работу с панелью здоровья',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final emailError = state.maybeMap(
                        form: (state) => state.emailError,
                        orElse: () => null,
                      );

                      final isEnabled = state.maybeMap(
                        loading: (_) => false,
                        orElse: () => true,
                      );

                      return TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: isEnabled,
                        onChanged: (value) {
                          context.read<LoginBloc>().add(
                            LoginEvent.emailChanged(value),
                          );
                        },
                        onSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Электронная почта',
                          hintText: 'Введите вашу почту',
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText: emailError,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final passwordError = state.maybeMap(
                        form: (state) => state.passwordError,
                        orElse: () => null,
                      );

                      final isPasswordVisible = state.maybeMap(
                        form: (state) => state.isPasswordVisible,
                        orElse: () => false,
                      );

                      final isEnabled = state.maybeMap(
                        loading: (_) => false,
                        orElse: () => true,
                      );

                      return TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: isEnabled,
                        onChanged: (value) {
                          context.read<LoginBloc>().add(
                            LoginEvent.passwordChanged(value),
                          );
                        },
                        onSubmitted: (_) {
                          _handleLogin();
                        },
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          hintText: 'Введите ваш пароль',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          errorText: passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              context.read<LoginBloc>().add(
                                const LoginEvent.togglePasswordVisibility(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Функция восстановления пароля скоро появится',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Забыли пароль?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final isLoading = state.maybeMap(
                        loading: (_) => true,
                        orElse: () => false,
                      );

                      final isValid = state.maybeMap(
                        form: (state) => state.isValid,
                        orElse: () => false,
                      );

                      return ElevatedButton(
                        onPressed: (isLoading || !isValid)
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : const Text(
                                'Войти',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ИЛИ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to register screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Функция регистрации скоро появится'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      'Создать аккаунт',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo Credentials (for testing - remove in production)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Демо-данные',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Почта: demo@erna.com\nПароль: password123',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Используйте error@test.com для проверки обработки ошибок',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
