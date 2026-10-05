/// [PRE-WRITTEN — provided by trainer; walkthrough only, no edits needed.]
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // generated: `flutterfire configure`
import 'screens/game_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SnakeXApp());
}

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · App root
/// SYLLABUS: explicit route navigation + APPLICATION state.
///
/// Application (app-wide) state here = "who is signed in?" — held by
/// FirebaseAuth itself and observed via ONE StreamBuilder at the root.
/// Every game tick, by contrast, is EPHEMERAL state (setState) local to
/// the GameScreen. Knowing WHICH bucket state belongs in is the lesson.
/// ─────────────────────────────────────────────────────────────────────────
class SnakeXApp extends StatelessWidget {
  const SnakeXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeX Cloud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
          brightness: Brightness.dark,
        ),
      ),
      // SYLLABUS: EXPLICIT ROUTES — named, push/pop navigation.
      routes: {
        '/': (_) => const AuthGate(),
        '/game': (_) => const GameScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
      },
    );
  }
}

/// Root-level StreamBuilder on the auth STATE stream:
/// sign in → GameScreen, sign out → LoginScreen. Zero setState involved.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) => snapshot.data == null
          ? const LoginScreen()
          : const GameScreen(),
    );
  }
}
