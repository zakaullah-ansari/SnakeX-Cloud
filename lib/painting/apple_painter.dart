import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — ApplePainter
/// SYLLABUS: CustomPainter. Boilerplate is pre-written; you paint 4 layers.
/// Paint order = layer order (like Photoshop): glow → body → stem → leaf.
/// v2: STEP 9 adds a golden palette for the 3× fruit.
/// ─────────────────────────────────────────────────────────────────────────
class ApplePainter extends CustomPainter {
  /// 0.0..1.0 breathing-glow amount, driven by the game tick.
  final double pulse;

  /// 🌟 Golden apples (every 5th) — worth 3× score. [STEP 9]
  final bool golden;

  const ApplePainter({this.pulse = 0.5, this.golden = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.30;

    // Placeholder so the starter SHOWS something — a flat colored circle.
    canvas.drawCircle(
        center,
        radius,
        Paint()..color = golden ? Colors.amber : Colors.red);

    // TODO(STEP 6): replace the placeholder with production layers —
    //  1) GLOW: drawCircle with MaskFilter.blur + opacity scaled by `pulse`
    //  2) BODY: drawCircle with a RadialGradient shader (highlight top-left)
    //  3) STEM: drawLine (strokeWidth 2, StrokeCap.round)
    //  4) LEAF: drawOval above-right of the stem
    // TODO(STEP 9 · BONUS): if `golden`, swap reds for an amber/yellow
    //  palette, glow harder (opacity ~0.55), and add 2 small white glint
    //  circles so players spot the 3× prize instantly.
    // Trainer hint: open solution/lib/painting/apple_painter.dart side by side.
  }

  @override
  bool shouldRepaint(ApplePainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.golden != golden;
}
