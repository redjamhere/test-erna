# Login Screen & LoginBloc Documentation

## Overview
The login screen provides a beautiful, user-friendly authentication interface with real-time validation, proper error handling, and smooth UX.

## Architecture

### LoginBloc
Manages the login form state and validation using the BLoC pattern with Freezed.

#### States
```dart
- initial: Initial state when screen loads
- form: Active form state with validation
  - email: String
  - password: String
  - emailError: String? (validation error)
  - passwordError: String? (validation error)
  - isPasswordVisible: bool
  - isValid: bool (both fields valid)
- loading: Submitting credentials
- success: Login successful (triggers navigation)
- error: Login failed (shows error message)
```

#### Events
```dart
- emailChanged(String email): User types in email field
- passwordChanged(String password): User types in password field
- togglePasswordVisibility(): Show/hide password
- submit(): Submit login form
- clearError(): Clear error state
```

## Features

### 1. **Real-time Validation**
- Email validation (format check)
- Password validation (min 6 characters)
- Instant feedback as user types
- Submit button disabled until form is valid

### 2. **Email Validation Rules**
```dart
✅ Required field
✅ Valid email format (user@domain.com)
❌ Empty string
❌ Invalid format
```

### 3. **Password Validation Rules**
```dart
✅ Required field
✅ Minimum 6 characters
❌ Empty string
❌ Less than 6 characters
```

### 4. **Password Visibility Toggle**
- Eye icon to show/hide password
- Maintains state during typing
- Improves UX for password entry

### 5. **Loading States**
- Disable form during submission
- Show loading spinner in button
- Prevent multiple submissions

### 6. **Error Handling**
- Field-level errors (red text under inputs)
- Global errors (snackbar for login failures)
- Clear error messages
- Retry functionality

### 7. **Keyboard Handling**
- Proper text input actions (next/done)
- Focus management between fields
- Submit on Enter key
- Dismiss keyboard on submit

### 8. **Autofill Support**
- Email autofill hints
- Password autofill hints
- Better integration with password managers

## UI Components

### Layout Structure
```
Scaffold
└── SafeArea
    └── Center
        └── SingleChildScrollView
            └── Column
                ├── Logo (circular with icon)
                ├── Welcome Text
                ├── Email TextField
                ├── Password TextField
                ├── Forgot Password Button
                ├── Sign In Button
                ├── Divider with "OR"
                ├── Create Account Button
                └── Demo Credentials (dev only)
```

### Visual Elements

#### 1. Logo
- Circular container with watch icon
- Primary color border
- Subtle background color
- 100x100 pixels

#### 2. Welcome Section
- "Welcome Back" headline
- Subtitle: "Sign in to continue..."
- Centered text
- Theme-aware colors

#### 3. Email Field
- Email icon prefix
- Placeholder text
- Real-time validation
- Error message display

#### 4. Password Field
- Lock icon prefix
- Visibility toggle suffix
- Obscure text option
- Real-time validation
- Error message display

#### 5. Sign In Button
- Full-width elevated button
- Loading spinner when submitting
- Disabled when form invalid
- Primary color background

#### 6. Create Account Button
- Full-width outlined button
- Secondary action
- Primary color border

## Usage Examples

### 1. Basic Usage in Router
```dart
AutoRoute(page: LoginRoute.page),
```

### 2. Handling Login Success
```dart
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    state.maybeWhen(
      success: (email, userId) {
        // Authenticate with AuthBloc
        context.read<AuthBloc>().add(
          AuthEvent.loginWithEmailPassword(
            email: email,
            password: password,
          ),
        );
        // Navigate to main screen
        context.router.replace(const MainRoute());
      },
      orElse: () {},
    );
  },
)
```

### 3. Displaying Validation Errors
```dart
BlocBuilder<LoginBloc, LoginState>(
  builder: (context, state) {
    final emailError = state.maybeMap(
      form: (state) => state.emailError,
      orElse: () => null,
    );
    
    return TextField(
      decoration: InputDecoration(
        errorText: emailError,
      ),
    );
  },
)
```

### 4. Handling Form Submission
```dart
void _handleLogin() {
  // Unfocus text fields
  _emailFocusNode.unfocus();
  _passwordFocusNode.unfocus();
  
  // Submit login
  context.read<LoginBloc>().add(const LoginEvent.submit());
}
```

## Validation Flow

```
User types in email field
        ↓
LoginBloc.emailChanged(email)
        ↓
_validateEmail(email)
        ↓
    ┌───────────────┐
    │ Email valid?  │
    └───┬───────┬───┘
        │       │
       Yes     No
        │       │
        ↓       ↓
    null    Error message
        │       │
        └───┬───┘
            ↓
    Update form state
    (emailError = result)
            ↓
    Check overall validity
    (isValid = emailError == null && passwordError == null)
            ↓
    Emit new form state
            ↓
    UI updates automatically
```

## Integration with AuthBloc

The LoginBloc handles **form validation and UI state**, while AuthBloc handles **actual authentication**:

```
LoginBloc                     AuthBloc
    │                            │
    ├─ Validate email/password   │
    ├─ Show loading              │
    ├─ Emit success              │
    │                            │
    └──────────────────────────► │
         Trigger login           │
                                 ├─ Call API
                                 ├─ Save tokens
                                 ├─ Update auth state
                                 └─ Navigate
```

## Error Scenarios

### 1. Invalid Email Format
```
Input: "test@"
Error: "Please enter a valid email address"
```

### 2. Empty Password
```
Input: ""
Error: "Password is required"
```

### 3. Short Password
```
Input: "abc"
Error: "Password must be at least 6 characters"
```

### 4. Login Failure (API)
```
Response: 401 Unauthorized
Display: SnackBar with error message
Action: Allow retry
```

### 5. Network Error
```
Error: Connection timeout
Display: SnackBar with "Check your connection"
Action: Allow retry
```

## Demo Credentials

For testing purposes, the screen shows demo credentials:

```
✅ Working Login:
Email: demo@smartwatch.com
Password: password123

❌ Error Test:
Email: error@test.com
Password: anything
→ Shows error handling
```

**Note:** Remove demo credentials section in production!

## Theme Support

### Light Theme
- Background: Light gray (#F8FAFC)
- Text: Dark gray (#1E293B)
- Primary: Blue (#3B82F6)
- Error: Red (#EF4444)

### Dark Theme
- Background: Dark blue (#0F172A)
- Text: Light gray (#F1F5F9)
- Primary: Light blue (#60A5FA)
- Error: Light red (#F87171)

## Accessibility

- ✅ Semantic labels on icons
- ✅ High contrast colors
- ✅ Readable font sizes
- ✅ Keyboard navigation
- ✅ Screen reader support
- ✅ Focus indicators
- ✅ Error announcements

## Best Practices Implemented

1. ✅ **Separation of Concerns**: BLoC handles logic, UI handles display
2. ✅ **Real-time Validation**: Instant feedback
3. ✅ **Freezed for Immutability**: Type-safe states
4. ✅ **Proper Resource Cleanup**: Dispose controllers and focus nodes
5. ✅ **Loading States**: Clear indication of async operations
6. ✅ **Error Recovery**: Users can retry after errors
7. ✅ **Keyboard Handling**: Smooth text input experience
8. ✅ **Responsive Design**: Works on all screen sizes

## Testing

### Unit Tests (LoginBloc)
```dart
blocTest<LoginBloc, LoginState>(
  'emits error when email is invalid',
  build: () => LoginBloc(),
  act: (bloc) => bloc.add(const LoginEvent.emailChanged('invalid')),
  expect: () => [
    predicate<LoginState>((state) {
      return state.maybeMap(
        form: (s) => s.emailError != null,
        orElse: () => false,
      );
    }),
  ],
);
```

### Widget Tests
```dart
testWidgets('shows error when submitting invalid form', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginScreen()),
  );
  
  await tester.tap(find.text('Sign In'));
  await tester.pump();
  
  expect(find.text('Email is required'), findsOneWidget);
});
```

## Customization

### Change Validation Rules
```dart
// In login_bloc.dart
String? _validatePassword(String password) {
  if (password.length < 8) { // Change from 6 to 8
    return 'Password must be at least 8 characters';
  }
  // Add complexity rules
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain uppercase letter';
  }
  return null;
}
```

### Change UI Colors
```dart
// Logo background
color: colorScheme.secondary.withOpacity(0.1),

// Button style
backgroundColor: colorScheme.secondary,
```

### Add Social Login
```dart
// Add after divider
ElevatedButton.icon(
  onPressed: () => _loginWithGoogle(),
  icon: Icon(Icons.g_mobiledata),
  label: Text('Continue with Google'),
)
```

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  freezed_annotation: ^3.1.0
  auto_route: ^9.2.2
  
dev_dependencies:
  freezed: ^3.2.3
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
```

## Build Command

After creating or modifying the LoginBloc:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Security Considerations

1. 🔒 **Never log passwords** in debug/error messages
2. 🔒 **Use HTTPS** for API calls
3. 🔒 **Implement rate limiting** to prevent brute force
4. 🔒 **Hash passwords** on backend
5. 🔒 **Use secure storage** for tokens (flutter_secure_storage)
6. 🔒 **Implement 2FA** for additional security
7. 🔒 **Add CAPTCHA** after multiple failed attempts

## Future Enhancements

- [ ] Biometric login option
- [ ] "Remember me" checkbox
- [ ] Social login (Google, Apple)
- [ ] Password strength indicator
- [ ] Email verification flow
- [ ] Multi-language support
- [ ] Forgot password implementation
- [ ] Registration screen
- [ ] Account recovery
- [ ] Login history tracking
