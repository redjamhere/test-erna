# Splash Screen Documentation

## Overview
The `SplashScreen` is the initial screen shown when the app launches. It handles authentication checking and biometric verification before navigating to the appropriate screen.

## Flow Diagram

```
App Launch
    ↓
SplashScreen
    ↓
Check Auth Status (AuthBloc)
    ↓
    ├─── Unauthenticated ────→ LoginScreen
    ↓
    ├─── Error ──────────────→ Show Error → LoginScreen
    ↓
    └─── Authenticated
            ↓
            Check Biometric Available?
            ↓
            ├─── No ─────────────────→ MainScreen
            ↓
            └─── Yes
                    ↓
                    Check Biometric Enabled?
                    ↓
                    ├─── No ─────────────→ MainScreen
                    ↓
                    └─── Yes
                            ↓
                            Show Biometric Auth
                            ↓
                            ├─── Success ────→ MainScreen
                            ├─── Failure ────→ Dialog (Try Again / Logout)
                            └─── Error ──────→ Dialog (Continue / Logout)
```

## Features

### 1. **Animated Splash**
- Smooth fade-in and scale animations
- App logo with pulse effect
- Loading indicator with status text

### 2. **Authentication Check**
- Automatically checks if user has valid session
- Uses AuthBloc for state management
- Handles all auth states (initial, loading, authenticated, unauthenticated, error)

### 3. **Biometric Authentication**
- Checks if biometric is available on device
- Respects user's biometric preference settings
- Shows native biometric prompt (Face ID, Touch ID, Fingerprint)
- Graceful fallback if biometric not available

### 4. **Error Handling**
- Handles authentication errors gracefully
- Shows user-friendly error dialogs
- Provides options to retry or logout
- Shows error messages via SnackBar

### 5. **Smart Navigation**
- Uses auto_route for type-safe navigation
- Automatically navigates to the correct screen
- No back button on splash (prevents returning to splash)

## Code Structure

### State Management
```dart
// BlocListener handles navigation based on auth state
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    state.when(
      authenticated: (userId, email) => _handleAuthenticated(userId, email),
      unauthenticated: () => _navigateToLogin(),
      error: (message) => _showErrorAndNavigate(message),
      // ... other states
    );
  },
  child: // UI Widget
)
```

### Biometric Flow
```dart
Future<void> _handleAuthenticated(String userId, String email) async {
  final localAuthRepo = CompositionRoot.get<LocalAuthRepository>();
  
  // 1. Check if biometric hardware is available
  final canUseBiometric = await localAuthRepo.isBiometricAvailable();
  
  if (canUseBiometric) {
    // 2. Check if user has enabled biometric in settings
    final isBiometricEnabled = await localAuthRepo.isBiometricEnabled();
    
    if (isBiometricEnabled) {
      // 3. Show biometric authentication
      await _authenticateWithBiometric(localAuthRepo);
    } else {
      // Skip biometric, go to main
      _navigateToMain();
    }
  } else {
    // No biometric available, go to main
    _navigateToMain();
  }
}
```

## UI Components

### 1. **Logo Container**
- Circular container with app icon
- Animated fade and scale
- Theme-aware colors

### 2. **App Name**
- Main title: "Smart Watch"
- Subtitle: "Health Data Monitor"
- Responsive typography

### 3. **Loading Indicator**
- Shows different messages based on state:
  - "Checking authentication..."
  - "Verifying biometric..."
- Themed progress indicator

### 4. **Version Info**
- Shows app version at bottom
- Subtle opacity for non-intrusive display

## Error Dialogs

### Biometric Failed Dialog
```dart
AlertDialog(
  title: 'Authentication Failed',
  content: 'Biometric authentication failed...',
  actions: [
    TextButton('Logout'),
    ElevatedButton('Try Again'),
  ],
)
```

### Biometric Error Dialog
```dart
AlertDialog(
  title: 'Error',
  content: 'An error occurred during authentication...',
  actions: [
    TextButton('Logout'),
    ElevatedButton('Continue Anyway'),
  ],
)
```

## Theme Support

The splash screen fully supports both light and dark themes:

```dart
final isDark = theme.brightness == Brightness.dark;

Scaffold(
  backgroundColor: isDark
      ? theme.colorScheme.background
      : theme.colorScheme.surface,
  // ...
)
```

## Navigation Methods

### Navigate to Main Screen
```dart
void _navigateToMain() {
  if (mounted) {
    context.router.replace(const MainRoute());
  }
}
```

### Navigate to Login Screen
```dart
void _navigateToLogin() {
  if (mounted) {
    // Logout user first
    context.read<AuthBloc>().add(const AuthEvent.logout());
    context.router.replace(const LoginRoute());
  }
}
```

## Dependencies

### Required Packages
- `flutter_bloc` - State management
- `auto_route` - Navigation
- `get_it` - Dependency injection

### Required Components
- `AuthBloc` - Authentication state management
- `LocalAuthRepository` - Biometric authentication
- `CompositionRoot` - Dependency injection setup
- `AppRouter` - Route configuration

## Usage

The SplashScreen is automatically set as the initial route in `AppRouter`:

```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    // ... other routes
  ];
}
```

## Customization

### Change Animation Duration
```dart
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1500), // Change this
);
```

### Change Biometric Reason
```dart
final authenticated = await localAuthRepo.authenticateWithBiometrics(
  localizedReason: 'Your custom message here',
);
```

### Change Logo Icon
```dart
Icon(
  Icons.favorite, // Change this
  size: 64,
  color: theme.colorScheme.primary,
)
```

## Testing

### Unit Testing
```dart
testWidgets('SplashScreen shows loading indicator', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: SplashScreen()),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Integration Testing
```dart
testWidgets('SplashScreen navigates to login when unauthenticated', (tester) async {
  // Setup mock AuthBloc to return unauthenticated state
  // Pump widget
  // Verify navigation to LoginScreen
});
```

## Troubleshooting

### Issue: Splash screen shows indefinitely
**Solution**: Check if AuthBloc is properly initialized in CompositionRoot

### Issue: Biometric dialog not showing
**Solution**: 
1. Check device permissions
2. Verify biometric is enabled in LocalAuthRepository
3. Check platform-specific setup (iOS Info.plist, Android permissions)

### Issue: Navigation not working
**Solution**: 
1. Ensure router files are generated: `dart run build_runner build`
2. Check if routes are properly defined in AppRouter

## Best Practices

1. ✅ Always check `mounted` before navigation
2. ✅ Use `replace` instead of `push` for authentication flows
3. ✅ Handle all possible auth states
4. ✅ Provide clear error messages to users
5. ✅ Test on both light and dark themes
6. ✅ Test with and without biometric hardware

## Future Enhancements

- [ ] Add skip button for emergency access
- [ ] Add network connectivity check
- [ ] Add app update check
- [ ] Add crash recovery from previous session
- [ ] Add custom animations based on time of day
- [ ] Add accessibility improvements (screen reader support)
