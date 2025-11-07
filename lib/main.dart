import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_erna/core/bloc/auth_bloc/auth_bloc.dart';
import 'package:test_erna/core/router/app_router.dart';
import 'core/theme.dart';
import 'core/composition_root.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies (DAOs, Repositories, BLoCs, Services, Router)
  await CompositionRoot.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get router and AuthBloc from dependency injection
    final appRouter = CompositionRoot.get<AppRouter>();
    final authBloc = CompositionRoot.get<AuthBloc>();

    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'ERNA Test app',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
