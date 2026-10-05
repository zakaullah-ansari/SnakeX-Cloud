import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · LoginScreen
/// SYLLABUS: Firebase Authentication (anonymous + email/password)
///           + exception handling via `on FirebaseAuthException`.
/// PRE-BUILT in the starter repo — walked through in Block 3, not live-coded.
/// ─────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  /// One shared runner for all three sign-in paths — try/catch lives here.
  Future<void> _run(Future<UserCredential> Function() signIn) async {
    setState(() => _busy = true);
    try {
      await signIn();
      // AuthGate (StreamBuilder at the root) swaps the screen for us.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign-in failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐍', style: TextStyle(fontSize: 56)),
                const Text(
                  'SnakeX Cloud',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_busy) const CircularProgressIndicator(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _run(
                      () => FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _email.text.trim(),
                        password: _password.text,
                      ),
                    ),
                    child: const Text('Sign in'),
                  ),
                ),
                TextButton(
                  onPressed: () => _run(
                    () => FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _email.text.trim(),
                      password: _password.text,
                    ),
                  ),
                  child: const Text('Create account'),
                ),
                const Divider(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Play anonymously (1 tap)'),
                  onPressed: () => _run(FirebaseAuth.instance.signInAnonymously),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
