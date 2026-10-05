import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — LeaderboardService
/// SYLLABUS: Firestore CRUD + Streams. CREATE is pre-written (network
/// boilerplate); YOU build the live QUERY STREAM + the StreamBuilder UI.
/// ─────────────────────────────────────────────────────────────────────────
class LeaderboardService {
  static final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('leaderboard');

  /// CREATE — PRE-WRITTEN. One .add() = one row in the cloud spreadsheet.
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
        'createdAt': FieldValue.serverTimestamp(), // server clock = no cheating
      });
    } catch (e) {
      // ignore: avoid_print
      print('Leaderboard sync failed (score kept locally): $e');
    }
  }

  /// READ (live).
  /// TODO(STEP 8): return the top-10 QUERY STREAM — chain three calls on
  /// _col: orderBy('score', descending: true) → limit(10) → snapshots()
  static Stream<QuerySnapshot<Map<String, dynamic>>> topTenStream() {
    return const Stream.empty(); // ← replace with your 4-line chain
  }
}
