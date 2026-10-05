import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/leaderboard_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — LeaderboardPanel
/// SYLLABUS: StreamBuilder + ListView.builder.
/// The ListTile row design is pre-written; YOU wire the stream + states.
/// ─────────────────────────────────────────────────────────────────────────
class LeaderboardPanel extends StatelessWidget {
  const LeaderboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(STEP 8): wrap everything below in a
    //   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    //     stream: LeaderboardService.topTenStream(),
    //     builder: (context, snapshot) { ... },
    //   )
    // Handle 3 states inside the builder:
    //   snapshot.hasError            → 'offline' Text
    //   ConnectionState.waiting      → CircularProgressIndicator
    //   data                         → the ListView.builder below,
    //                                  fed by snapshot.data?.docs
    return const Center(
      child: Text('TODO Step 8: stream the global top 10 live 🌍'),
    );

    // PRE-WRITTEN row renderer — move it inside your builder:
    //
    // ListView.builder(
    //   itemCount: docs.length,
    //   itemBuilder: (context, i) {
    //     final entry = docs[i].data();
    //     return ListTile(
    //       leading: CircleAvatar(child: Text('#${i + 1}')),
    //       title: Text(entry['name'] as String? ?? 'Anonymous Snake'),
    //       trailing: Text('${entry['score']} pts'),
    //     );
    //   },
    // );
  }
}
