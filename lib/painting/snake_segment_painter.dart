/// [PRE-WRITTEN — provided by trainer; walkthrough only, no edits needed.]
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PRE-WRITTEN (demo file for Block 2) — students read, then build
/// ApplePainter by analogy. Shows rounded RRect + conditional head eyes.
/// ─────────────────────────────────────────────────────────────────────────
class SnakeSegmentPainter extends CustomPainter {
  final bool isHead;
  const SnakeSegmentPainter({this.isHead = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isHead ? const Color(0xFF7CFC00) : const Color(0xFF2ECC71);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(1.5),
        const Radius.circular(6),
      ),
      paint,
    );

    if (isHead) {
      final eyePaint = Paint()..color = Colors.black87;
      final cx = size.width / 2, cy = size.height / 2;
      canvas.drawCircle(Offset(cx - 4, cy - 2), 1.9, eyePaint);
      canvas.drawCircle(Offset(cx + 4, cy - 2), 1.9, eyePaint);
    }
  }

  @override
  bool shouldRepaint(SnakeSegmentPainter oldDelegate) =>
      oldDelegate.isHead != isHead;
}
