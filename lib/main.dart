import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';

// ── Jongkuch's screens (auth + outlook) ──────────────────────────────────────
import 'presentation/screens/app_outlook_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/verify_email_screen.dart';

// ── Other team members' screens (added here when branches are merged) ─────────
// import 'presentation/screens/course_completion_screen.dart';
// import 'presentation/screens/mentorship_hub_screen.dart';
// import 'presentation/screens/profile_screen.dart';
// import 'presentation/screens/my_skills_screen.dart';
// import 'presentation/screens/preferences_screen.dart';
// import 'presentation/screens/discover_screen.dart';
// import 'presentation/screens/accessibility_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is provided at the root so every screen can access it.
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc()..add(AuthCheckRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inclusive Learning Platform',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF00D4D4),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          // '/' uses _AuthGate which checks persisted auth state and routes
          // the user to the correct screen automatically.
          '/': (context) => const _AuthGate(),

          // ── Jongkuch: App Outlook + Auth screens ──────────────────────────
          '/outlook': (context) => const OutlookScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),

          // ── Other team members' routes (uncomment when merging) ───────────
          // '/course-completion': (context) => const CourseCompletionScreen(),
          // '/mentorship-hub':    (context) => const MentorshipHubScreen(),
          // '/profile':           (context) => const ProfileScreen(),
          // '/skills':            (context) => const MySkillsScreen(),
          // '/preferences':       (context) => const PreferencesScreen(),
          // '/discover':          (context) => const DiscoverScreen(),
          // '/accessibility-setup':(context) => const AccessibilitySetupScreen(),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AuthGate — single source of truth for auth-based navigation.
//  Replaces the old hard-coded '/' → OutlookScreen mapping.
// ─────────────────────────────────────────────────────────────────────────────

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/outlook');
        } else if (state is AuthEmailVerificationRequired ||
            state is AuthEmailVerificationSent) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        }
      },
      builder: (context, state) {
        // Show the Outlook landing screen for unauthenticated / error states.
        if (state is AuthUnauthenticated || state is AuthError) {
          return const OutlookScreen();
        }
        // Show a splash while we resolve the persisted session.
        return const _SplashScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Splash screen — shown only during the initial Firebase auth check.
// ─────────────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF00D4D4),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Inclusive Learning Platform',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
