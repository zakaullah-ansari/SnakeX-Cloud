import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · SnakeSegmentPainter
/// SYLLABUS: CustomPainter — hand-drawn rounded snake cells. The original
/// Nokia snake was a row of square pixels; drawing a rounded RRect + eyes
/// is the "production polish" layer students can point at in interviews.
/// ─────────────────────────────────────────────────────────────────────────
class SnakeSegmentPainter extends CustomPainter {
  final bool isHead;
  const SnakeSegmentPainter({this.isHead = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Body: rounded rectangle, head in a brighter toxic-green.
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

    // Head only: two eyes so players can read the snake's facing.
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
