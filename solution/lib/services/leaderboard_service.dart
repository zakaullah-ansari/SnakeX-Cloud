import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · LeaderboardService
/// SYLLABUS: Cloud Firestore — real-time CRUD + Streams + try/catch.
///
/// Mental model: `collection('leaderboard')` is a cloud spreadsheet.
/// .add() appends a row; .snapshots() LIVE-STREAMS the sorted view —
/// no refresh button, no polling loop, Firestore PUSHES diffs to us.
/// ─────────────────────────────────────────────────────────────────────────
class LeaderboardService {
  static final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('leaderboard');

  /// CREATE — called exactly once per game over.
  /// FieldValue.serverTimestamp() avoids device-clock cheating/skew.
  static Future<void> submitScore({
    required String uid,
    required String name,
    required int score,
  }) async {
    try {
      await _col.add({
        'uid': uid,
        'name': name,
        'score': score,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // SYLLABUS: exception handling — never let a network hiccup
      // crash the game-over screen. Log and degrade gracefully.
      // ignore: avoid_print
      print('Leaderboard sync failed (score kept locally): $e');
    }
  }

  /// READ (live) — a QUERY STREAM of the global top 10.
  /// Every insert/update/delete on the backend re-emits here in <1s.
  static Stream<QuerySnapshot<Map<String, dynamic>>> topTenStream() => _col
      .orderBy('score', descending: true)
      .limit(10)
      .snapshots();

  /// STRETCH EXERCISE (U & D of CRUD): let players delete THEIR OWN
  /// entries → `_col.doc(id).delete()` guarded by
  /// `request.auth.uid == resource.data.uid` in firestore.rules.
}
