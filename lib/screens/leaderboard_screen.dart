/// [PRE-WRITTEN — provided by trainer; walkthrough only, no edits needed.]
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/leaderboard_panel.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · LeaderboardScreen — the global top 10, live.
/// SYLLABUS: explicit route target ('/leaderboard') + sign-out demo.
/// ─────────────────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard 🌍'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: const LeaderboardPanel(),
    );
  }
}
