/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · ScoreCalculationMixin
/// SYLLABUS: MIXINS — reusable behavior plugged into ANY class with `with`.
///
/// A mixin is NOT a parent class. `SnakeGameController` doesn't "extend"
/// score logic, it *mixes it in* — like attaching a turbocharger to an
/// engine without rebuilding the engine.
/// ─────────────────────────────────────────────────────────────────────────
library;

mixin ScoreCalculationMixin {
  static const int baseApplePoints = 10;

  /// Faster tick interval ⇒ harder game ⇒ bigger bonus (0–20 pts).
  /// tickMs 250 (slow) → +0 … tickMs 50 (blink-and-die) → +20.
  int speedBonus(int tickMilliseconds) {
    const slowestTick = 250;
    final clamped = tickMilliseconds.clamp(50, slowestTick);
    return ((slowestTick - clamped) / 10).round();
  }

  /// Every 5 body segments adds +1 — long-snake risk pays compound interest.
  int lengthBonus(int snakeLength) => snakeLength ~/ 5;

  /// What one apple is worth right now:
  /// points = BASE + speed risk premium + length risk premium.
  int scoreForApple({
    required int tickMilliseconds,
    required int snakeLength,
  }) =>
      baseApplePoints +
      speedBonus(tickMilliseconds) +
      lengthBonus(snakeLength);

  /// End-of-run arcade grade — shown on the game-over screen.
  String grade(int finalScore) => switch (finalScore) {
        >= 500 => 'S — Arcade Legend 🏆',
        >= 250 => 'A — Pixel Pro ⚡',
        >= 100 => 'B — Solid Snake 🐍',
        _ => 'C — Worm in Training 🌱',
      };
}
