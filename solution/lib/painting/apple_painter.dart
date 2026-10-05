import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · ApplePainter
/// SYLLABUS: CustomPainter — drawing commands straight to the GPU canvas.
/// Paint order = layer order: glow → body → sparkle → stem → leaf.
/// v2: [golden] swaps the palette to amber and adds white glints (3× fruit).
/// ─────────────────────────────────────────────────────────────────────────
class ApplePainter extends CustomPainter {
  /// 0.0..1.0 breathing-glow amount, driven by the game tick.
  final double pulse;

  /// 🌟 Golden apples (every 5th) — worth 3× score.
  final bool golden;

  const ApplePainter({this.pulse = 0.5, this.golden = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.30;

    // v2 palette switch — one flag, two personalities.
    final glowColor = golden ? Colors.amberAccent : Colors.redAccent;
    final bodyLight = golden ? Colors.yellow.shade200 : Colors.red.shade200;
    final bodyDark = golden ? Colors.orange.shade900 : Colors.red.shade800;

    // LAYER 1 · Neon glow — blurred halo, breathing with the pulse.
    // Goldens glow harder so players see the 3× prize from across the board.
    canvas.drawCircle(
      center,
      radius * (1.35 + 0.20 * pulse),
      Paint()
        ..color = glowColor.withOpacity((golden ? 0.55 : 0.35) * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // LAYER 2 · Body — radial gradient, top-left highlight = fake 3D.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [bodyLight, bodyDark],
          center: const Alignment(-0.35, -0.35),
          radius: 0.9,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // LAYER 3 · Sparkle (golden only) — two white glints.
    if (golden) {
      final glint = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(
          center + Offset(-radius * 0.30, -radius * 0.38), radius * 0.16, glint);
      canvas.drawCircle(
          center + Offset(radius * 0.28, -radius * 0.08), radius * 0.09, glint);
    }

    // LAYER 4 · Stem.
    canvas.drawLine(
      center + Offset(0, -radius * 0.9),
      center + Offset(radius * 0.25, -radius * 1.5),
      Paint()
        ..color = Colors.brown.shade700
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // LAYER 5 · Leaf.
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(radius * 0.62, -radius * 1.35),
        width: radius * 1.0,
        height: radius * 0.5,
      ),
      Paint()..color = Colors.greenAccent.shade400,
    );
  }

  @override
  bool shouldRepaint(ApplePainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.golden != golden;
}
