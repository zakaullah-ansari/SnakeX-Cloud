/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — ScoreCalculationMixin
/// SYLLABUS: MIXINS. Behavior you plug into any class with `with`.
/// The signatures are pre-written — implement the math (1 line each).
/// ─────────────────────────────────────────────────────────────────────────
library;

mixin ScoreCalculationMixin {
  static const int baseApplePoints = 10;

  /// Faster tick ⇒ harder game ⇒ bigger bonus, range 0–20.
  /// TODO(STEP 5): clamp tickMilliseconds to [50, 250], then map
  /// 250→0 and 50→20. Hint: ((250 - clamped) / 10).round()
  int speedBonus(int tickMilliseconds) => 0;

  /// Every 5 body segments = +1 bonus.
  /// TODO(STEP 5): one integer-division line (~/ operator).
  int lengthBonus(int snakeLength) => 0;

  /// One apple = base + speed premium + length premium.
  /// TODO(STEP 5): combine the three values above.
  int scoreForApple({
    required int tickMilliseconds,
    required int snakeLength,
  }) =>
      0;

  /// PRE-WRITTEN — arcade grade for the game-over dialog.
  String grade(int finalScore) => switch (finalScore) {
        >= 500 => 'S — Arcade Legend 🏆',
        >= 250 => 'A — Pixel Pro ⚡',
        >= 100 => 'B — Solid Snake 🐍',
        _ => 'C — Worm in Training 🌱',
      };
}
