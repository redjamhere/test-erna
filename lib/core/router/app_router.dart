import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

/// Main router configuration for the Smart Watch Data app
///
/// This uses auto_route for declarative navigation.
///
/// To generate the routes after making changes, run:
/// ```
/// dart run build_runner build --delete-conflicting-outputs
/// ```
/// Or for watch mode (auto-regenerates on changes):
/// ```
/// dart run build_runner watch --delete-conflicting-outputs
/// ```
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash screen - initial route
    AutoRoute(page: SplashRoute.page, initial: true),

    // Login screen
    AutoRoute(page: LoginRoute.page),

    // Main app screen with bottom navigation and nested routes
    AutoRoute(
      page: MainRoute.page,
      children: [
        // Dashboard tab
        AutoRoute(page: DashboardRoute.page, initial: true),
      ],
    ),
  ];

  @override
  RouteType get defaultRouteType => const RouteType.material();
}

/// Authentication guard to protect routes that require authentication
/// Uncomment and implement when you have authentication logic
// class AuthGuard extends AutoRouteGuard {
//   @override
//   void onNavigation(NavigationResolver resolver, StackRouter router) {
//     // Check if user is authenticated
//     final isAuthenticated = false; // Replace with actual auth check
//
//     if (isAuthenticated) {
//       // User is authenticated, continue navigation
//       resolver.next(true);
//     } else {
//       // User is not authenticated, redirect to login
//       resolver.redirect(const LoginRoute());
//     }
//   }
// }
