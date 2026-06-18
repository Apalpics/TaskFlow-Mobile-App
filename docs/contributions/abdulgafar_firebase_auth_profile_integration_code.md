# TaskFlow – Firebase Authentication, User Profile, and Final Integration Module

**Module:** Firebase Setup, Authentication, User Profile, and Final Integration  
**Contributor:** Abdulgafar Abdullahi Ibrahim  
**Matric Number:** 2311279  
**Course:** INFO 4335 – Mobile Application Development  
**Project:** TaskFlow: Smart Academic Task and Collaboration Management System  
**File Path:** `docs/contributions/abdulgafar_firebase_auth_profile_integration_code.md`

---

## 1. Contribution Summary

This file documents my individual contribution to the final TaskFlow Flutter/Firebase application. My assigned module was **Firebase Setup, Authentication, and User Profile**. During the final stage, I also handled **final integration**, meaning I connected the app modules together, checked that the app runs as one complete system, verified Firebase data, and prepared the project for GitHub submission and demo evidence.

My contribution focuses on:

- Initializing Firebase inside the Flutter app.
- Connecting the Flutter project to the Firebase project configuration.
- Implementing email/password user registration with Firebase Authentication.
- Saving registered user profile records into Cloud Firestore.
- Implementing email/password login using Firebase Authentication.
- Implementing user profile display from Firebase Auth and Firestore.
- Allowing the user to update their profile name.
- Implementing logout and returning the user to the login screen.
- Connecting the final app screens through route management and bottom navigation.
- Helping make the app ready for final GitHub submission and demo presentation.

---

## 2. My Main Responsibilities

| Area | What I Did |
|---|---|
| Firebase setup | Connected the Flutter app to Firebase using `firebase_options.dart` and initialized Firebase in `main.dart`. |
| Authentication | Built real email/password register and login logic using `firebase_auth`. |
| Firestore user profile | Saved user profile data into the `users` collection after registration. |
| Profile screen | Displayed the logged-in user's name and email and added edit-name functionality. |
| Logout | Added logout using `FirebaseAuth.instance.signOut()` and redirected the user to login. |
| App integration | Connected Dashboard, Assignments, Progress, Groups, Files, and Profile through bottom navigation. |
| Testing support | Checked the full app flow and used `flutter analyze` to confirm no analysis issues before final submission. |

---

## 3. Important Files I Worked With

```text
lib/main.dart
lib/firebase_options.dart
lib/core/routes/app_routes.dart
lib/core/theme/app_theme.dart
lib/features/auth/screens/register_screen.dart
lib/features/auth/screens/login_screen.dart
lib/features/profile/screens/profile_screen.dart
lib/features/dashboard/screens/main_navigation_screen.dart
```

These files are important because they control the start of the app, Firebase connection, authentication flow, user profile, logout, route structure, shared theme, and integrated navigation.

---

## 4. Firebase Project and Services Used

The app is connected to the Firebase project for TaskFlow. The final app uses:

1. **Firebase Authentication**  
   Used for email/password registration and login.

2. **Cloud Firestore**  
   Used for storing user profiles and app data such as assignments, group tasks, and file metadata.

Firebase Storage was not used for real binary file upload because the Firebase console required a pricing plan upgrade before enabling Storage. Therefore, the Files module stores file metadata in Firestore instead.

---

## 5. Firestore Collections Related to My Integration Work

| Collection | Purpose | Main Fields |
|---|---|---|
| `users` | Stores registered user profile records | `uid`, `name`, `email`, `profileImage`, `createdAt`, `updatedAt` |
| `assignments` | Stores assignment records used by dashboard/progress/reminders | `title`, `courseName`, `description`, `deadline`, `priority`, `status`, `createdBy`, `createdAt` |
| `groupTasks` | Stores group project tasks | `projectName`, `taskTitle`, `assignedTo`, `deadline`, `status`, `createdBy`, `createdAt` |
| `files` | Stores file metadata records | `fileName`, `fileType`, `assignmentTitle`, `note`, `uploadedBy`, `uploadedAt` |

My main direct Firestore responsibility was the `users` collection. As final integrator, I also made sure other collections were reachable through the final app navigation and Firebase setup.

---

## 6. Feature Explanation

### 6.1 Firebase Initialization

The app initializes Firebase before running the main widget. This is required because Firebase Authentication and Cloud Firestore cannot be used safely before Firebase is initialized.

Main file:

```text
lib/main.dart
```

The key part is:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
runApp(const TaskFlowApp());
```

This means the app waits for Firebase setup to finish first, then starts TaskFlow.

### 6.2 Route Setup

The app uses route constants to move between the login, register, and main home screens.

Main files:

```text
lib/main.dart
lib/core/routes/app_routes.dart
```

The important routes are:

```dart
AppRoutes.login
AppRoutes.register
AppRoutes.home
```

After successful login or registration, the user is sent to `AppRoutes.home`, which opens the main navigation screen.

### 6.3 Registration

The registration screen allows a user to create an account with:

- Full name
- Email address
- Password
- Confirm password

The form includes validation, such as checking that the name is not empty, email format is reasonable, password is at least 6 characters, and both passwords match.

After validation, Firebase Authentication creates the account:

```dart
FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
);
```

Then the app saves the profile data in Firestore:

```dart
FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  'uid': user.uid,
  'name': _nameController.text.trim(),
  'email': _emailController.text.trim(),
  'profileImage': '',
  'createdAt': FieldValue.serverTimestamp(),
});
```

This connects Firebase Authentication identity with a Firestore user profile document.

### 6.4 Login

The login screen allows a registered user to sign in with email and password.

Key logic:

```dart
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
);
```

If login is successful, the user is sent to the main TaskFlow screen:

```dart
Navigator.pushReplacementNamed(context, AppRoutes.home);
```

The login screen also includes error handling for invalid email, wrong password, disabled user, and network error.

### 6.5 Profile Screen

The profile screen reads the current logged-in user from Firebase Authentication:

```dart
final user = FirebaseAuth.instance.currentUser;
```

Then it listens to the Firestore profile document:

```dart
FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
```

This allows the profile screen to display the latest name and email.

The profile screen also allows editing the name. It updates both:

1. Firebase Authentication display name.
2. Firestore `users` document.

Key logic:

```dart
await user.updateDisplayName(newName);

await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  'uid': user.uid,
  'name': newName,
  'email': user.email ?? '',
  'profileImage': '',
  'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
```

### 6.6 Logout

The profile screen includes logout:

```dart
await FirebaseAuth.instance.signOut();
```

After logout, the app clears the navigation stack and returns to the login screen:

```dart
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.login,
  (route) => false,
);
```

This prevents the user from pressing back and returning to protected app screens after logout.

### 6.7 Final Module Integration

The final app uses a bottom navigation screen to connect the main modules:

- Dashboard
- Assignments
- Progress
- Groups
- Files
- Profile

Main file:

```text
lib/features/dashboard/screens/main_navigation_screen.dart
```

The screen uses `_currentIndex` to decide which module screen to show. This is a simple local state management approach using `setState`, which is acceptable for navigation state.

The Dashboard also has a reminders icon that opens the Reminders screen.

---

## 7. UI/UX Consistency

I helped keep the final app consistent by using the shared `AppTheme` file. Important design constants include:

```dart
AppTheme.primaryBlue
AppTheme.darkText
AppTheme.grayText
AppTheme.background
AppTheme.cardColor
AppTheme.success
AppTheme.warning
AppTheme.danger
```

The design style is:

- Clean academic productivity interface.
- Blue primary color `#3D52A0`.
- White cards.
- Light background.
- Rounded inputs and cards.
- Consistent icons.
- Simple navigation.

---

## 8. Testing Evidence for My Module

| Test | Action | Expected Result | Status |
|---|---|---|---|
| Firebase initialization | Run the app | App starts without Firebase initialization error | Pass |
| Register | Create new user with name, email, and password | User account appears in Firebase Authentication and profile appears in Firestore `users` | Pass |
| Login | Sign in with registered email/password | User enters the Dashboard/Home screen | Pass |
| Form validation | Submit empty/invalid fields | Helpful validation or error message appears | Pass |
| Profile display | Open Profile tab | User name and email appear | Pass |
| Edit name | Update profile name | Firestore profile record is updated | Pass |
| Logout | Tap logout | User returns to login screen and cannot remain in main app | Pass |
| Navigation | Tap bottom navigation tabs | Dashboard, Assignments, Progress, Groups, Files, and Profile open correctly | Pass |
| Code analysis | Run `flutter analyze` | No issues found | Pass |

---

## 9. Limitations and Future Improvements

### Current limitations

- Firebase Storage was not used because it required a Firebase pricing plan upgrade.
- Password reset was not added because the project deadline was short.
- Email verification was not added.
- Role-based accounts were not added.
- Advanced Firestore security rules can be improved later.

### Future improvements

- Add password reset by email.
- Add email verification before entering the app.
- Add student profile image upload after enabling Firebase Storage.
- Add role-based accounts such as student, team leader, or admin.
- Add stronger Firestore security rules.
- Add real push notifications using Firebase Cloud Messaging.
- Add offline support and better loading states.

---

## 10. How I Will Explain This in My Demo Video

In my individual video, I should show:

1. `main.dart` — Firebase initialization.
2. `firebase_options.dart` — Firebase configuration file.
3. `register_screen.dart` — creates Firebase Auth user and Firestore profile.
4. `login_screen.dart` — signs in using Firebase Authentication.
5. `profile_screen.dart` — displays name/email, edit name, logout.
6. `main_navigation_screen.dart` — integrates the modules through bottom navigation.
7. Firebase Console — Authentication users and Firestore `users` collection.
8. Running app — login, dashboard, navigation, profile, logout.
9. Terminal — `flutter analyze` showing no issues.

Short explanation:

> My contribution was Firebase setup, Authentication, User Profile, and final integration. I connected the Flutter app with Firebase, created login/register/profile/logout, stored user records in Firestore, connected the modules through bottom navigation, and tested the app until it had no analysis issues.

---

## 11. Code Appendix

The following code sections are taken from the final implemented TaskFlow Flutter project. They show the actual files related to my contribution and final integration work.

## Code Appendix — `lib/main.dart`

**Purpose:** Firebase initialization and app route registration.

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/main_navigation_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const MainNavigationScreen(),
      },
    );
  }
}

```

## Code Appendix — `lib/core/routes/app_routes.dart`

**Purpose:** Central route constants.

```dart
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addAssignment = '/add-assignment';
  static const String assignmentDetails = '/assignment-details';
}

```

## Code Appendix — `lib/core/theme/app_theme.dart`

**Purpose:** Shared TaskFlow theme and UI constants.

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF3D52A0);
  static const Color darkText = Color(0xFF1F2937);
  static const Color grayText = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F8FC);
  static const Color cardColor = Colors.white;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
  );
}

```

## Code Appendix — `lib/features/auth/screens/register_screen.dart`

**Purpose:** Firebase Authentication registration and Firestore user profile creation.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-created',
          message: 'Account could not be created.',
        );
      }

      await user.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Welcome to TaskFlow.'),
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getAuthErrorMessage(e)),
          backgroundColor: AppTheme.danger,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password registration is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join TaskFlow and organize your study tasks',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grayText, fontSize: 15),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) {
                          return 'Full name is required';
                        }
                        if (name.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Email is required';
                        }
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final password = value?.trim() ?? '';
                        if (password.isEmpty) {
                          return 'Password is required';
                        }
                        if (password.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final confirmPassword = value?.trim() ?? '';
                        if (confirmPassword.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (confirmPassword !=
                            _passwordController.text.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: AppTheme.grayText),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

## Code Appendix — `lib/features/auth/screens/login_screen.dart`

**Purpose:** Firebase Authentication login flow.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful. Welcome back to TaskFlow.'),
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getAuthErrorMessage(e)),
          backgroundColor: AppTheme.danger,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your academic tasks',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grayText, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Email is required';
                        }
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to TaskFlow?',
                          style: TextStyle(color: AppTheme.grayText),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

## Code Appendix — `lib/features/profile/screens/profile_screen.dart`

**Purpose:** Profile display, edit name, Firestore merge update, and logout.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) =>
          _EditNameDialog(controller: controller, formKey: formKey),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view profile.',
          style: TextStyle(color: AppTheme.grayText),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final nameFromFirestore = data?['name']?.toString();
        final displayName =
            nameFromFirestore == null || nameFromFirestore.trim().isEmpty
            ? (user.displayName == null || user.displayName!.trim().isEmpty
                  ? 'Student'
                  : user.displayName!)
            : nameFromFirestore;

        final email = user.email ?? data?['email']?.toString() ?? 'No email';

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your TaskFlow account information.',
                style: TextStyle(color: AppTheme.grayText, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Card(
                color: AppTheme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppTheme.primaryBlue.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primaryBlue,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.grayText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showEditNameDialog(context, displayName),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Name'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                color: AppTheme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Authentication',
                        value: 'Firebase Email Login',
                      ),
                      const Divider(height: 24),
                      _ProfileInfoRow(
                        icon: Icons.cloud_done_outlined,
                        title: 'Database',
                        value: 'Cloud Firestore Connected',
                      ),
                      const Divider(height: 24),
                      _ProfileInfoRow(
                        icon: Icons.storage_outlined,
                        title: 'File Storage',
                        value: 'Metadata only, no Firebase Storage',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.controller, required this.formKey});

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  bool _isSaving = false;

  Future<void> _saveName() async {
    if (!widget.formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final newName = widget.controller.text.trim();

      await user.updateDisplayName(newName);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': newName,
        'email': user.email ?? '',
        'profileImage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not update profile: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile Name'),
      content: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.controller,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            if (value.trim().length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveName,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(color: AppTheme.grayText, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

```

## Code Appendix — `lib/features/dashboard/screens/main_navigation_screen.dart`

**Purpose:** Final bottom navigation integration for all modules.

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../assignments/screens/assignments_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../files/screens/files_screen.dart';
import '../../files/screens/reminders_screen.dart';
import '../../groups/screens/group_tasks_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'Assignments',
    'Progress',
    'Groups',
    'Files',
    'Profile',
  ];

  Widget _getScreen() {
    switch (_currentIndex) {
      case 1:
        return const AssignmentsScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return const GroupTasksScreen();
      case 4:
        return const FilesScreen();
      case 5:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              tooltip: 'Reminders',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                );
              },
              icon: const Icon(Icons.notifications_none_outlined),
            ),
        ],
      ),
      body: SizedBox.expand(child: _getScreen()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.grayText,
        backgroundColor: AppTheme.cardColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

```
