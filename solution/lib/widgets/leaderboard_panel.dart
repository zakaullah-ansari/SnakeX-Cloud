import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/leaderboard_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · LeaderboardPanel
/// SYLLABUS: StreamBuilder + ListView.builder + Firestore live query.
///
/// StreamBuilder is a live TV subscription (FutureBuilder was a one-time
/// photo): every score submitted by ANY player ANYWHERE re-renders this
/// list on every student device in the room — the "wow" demo moment.
/// ─────────────────────────────────────────────────────────────────────────
class LeaderboardPanel extends StatelessWidget {
  const LeaderboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // ① THE STREAM — an ordered top-10 query, re-emitted on every change.
      stream: LeaderboardService.topTenStream(),
      builder: (context, snapshot) {
        // ② Handle EVERY stream state explicitly (no silent white screens).
        if (snapshot.hasError) {
          return const Center(child: Text('Leaderboard offline 📡'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? const [];

        // ③ SYLLABUS: ListView.builder — lazy, scrollable, scalable.
        final myUid = FirebaseAuth.instance.currentUser?.uid;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final entry = docs[i].data();
            // v2 UX: highlight MY row — instant "where am I?" on the board.
            final isMe = entry['uid'] == myUid;
            return ListTile(
              tileColor: isMe ? const Color(0x227CFC00) : null,
              leading: CircleAvatar(
                backgroundColor:
                    i == 0 ? Colors.amber : Colors.blueGrey.shade800,
                child: Text('#${i + 1}'),
              ),
              title: Text(
                (entry['name'] as String? ?? 'Anonymous Snake') +
                    (isMe ? ' (you)' : ''),
                style: isMe
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              ),
              trailing: Text(
                '${entry['score']} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF7CFC00),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
