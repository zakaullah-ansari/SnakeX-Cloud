import 'dart:async';
import 'dart:math';

import '../mixins/score_calculation_mixin.dart';
import '../models/game_models.dart';

/// ── v2 · PURE DIFFICULTY CURVE ────────────────────────────────────────────
/// Every 4 apples eaten, the tick shortens by 15ms (floor: 90ms).
/// Pure function → zero state → trivially unit-testable (see test/).
int tickMsForApples(int applesEaten, {int base = 180}) {
  final floor = base < 90 ? base : 90;
  final t = base - (applesEaten ~/ 4) * 15;
  return t < floor ? floor : t;
}

/// ── v2 · LIFECYCLE STATE MACHINE ──────────────────────────────────────────
/// The UI's overlay Stack mirrors these phases 1:1.
enum GamePhase { ready, playing, paused, gameOver }

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · SnakeGameController — the pure-Dart game brain.
/// ZERO Flutter imports ⇒ unit-testable in `flutter test`.
///
/// SYLLABUS: async (Future.delayed loop) · mixins · OOP composition
/// v2: pause-aware loop, speed ramping, golden apples (🌟 3×).
/// v3: golden TTL — goldens despawn after [goldenTtlTicks] ticks uneaten.
/// ─────────────────────────────────────────────────────────────────────────
class SnakeGameController with ScoreCalculationMixin {
  static const int gridSize = 20; // 20×20 matrix = 400 cells
  static const int defaultTickMs = 180;
  static const int goldenMultiplier = 3; // golden apples pay 3×

  /// 🌟 Golden apples vanish after this many ticks uneaten
  /// (30 ticks ≈ 5.4s at start speed — less as the game accelerates!).
  static const int goldenTtlTicks = 30;

  final void Function() onTick; // wired to setState() in the widget
  final Random _rng = Random();
  final int baseTickMs; // starting speed (tests inject 1ms)

  late Snake snake;
  Apple? apple;

  int score = 0;
  int applesEaten = 0;
  int goldenEaten = 0;
  int tickMs = defaultTickMs;

  /// Ticks left before the current golden apple despawn. 0 = no golden out.
  /// Public read-only by convention (the HUD counts down with it).
  int goldenTicksLeft = 0;

  GamePhase _phase = GamePhase.ready;
  GamePhase get phase => _phase;
  bool get isGameOver => _phase == GamePhase.gameOver;
  bool get isPlaying => _phase == GamePhase.playing;
  bool get isPaused => _phase == GamePhase.paused;

  /// HUD-friendly speed readout: 1.0× → 2.0× as the curve ramps.
  double get speedRatio => defaultTickMs / tickMs;

  /// Buffered input: a fast UP→LEFT inside one tick can't 180° the snake.
  Direction _pending = Direction.right;

  SnakeGameController({required this.onTick, this.baseTickMs = defaultTickMs}) {
    reset();
  }

  void reset() {
    snake = Snake();
    applesEaten = 0;
    goldenEaten = 0;
    tickMs = baseTickMs;
    score = 0;
    goldenTicksLeft = 0;
    apple = _spawnApple();
    _pending = Direction.right;
    _phase = GamePhase.ready; // waits behind the TAP TO START overlay
  }

  // ── v2 lifecycle controls (UI calls these; every change notifies) ──
  void begin() => _setPhase(GamePhase.playing);
  void pause() {
    if (isPlaying) _setPhase(GamePhase.paused);
  }

  void resume() {
    if (isPaused) _setPhase(GamePhase.playing);
  }

  void dispose() => _phase = GamePhase.gameOver; // stops the loop quietly

  void _setPhase(GamePhase p) {
    if (_phase == p) return;
    _phase = p;
    onTick(); // refresh overlays/HUD immediately
  }

  void changeDirection(Direction dir) {
    if (!dir.isOppositeOf(snake.direction)) _pending = dir;
  }

  /// ── THE GAME LOOP (pause-aware in v2) ─────────────────────────────────
  /// Same beginner-safe self-rescheduling Future.delayed pattern — but the
  /// loop now IDLES while ready/paused instead of dying with the game.
  Future<void> start({bool autoBegin = true}) async {
    if (autoBegin) begin();
    while (!isGameOver) {
      await Future.delayed(Duration(milliseconds: tickMs)); // ← the "tick"
      if (!isPlaying) continue; // ready/paused: overlays freeze the sim
      _step(); // timers + advance 1 cell
      onTick(); // → setState(() {}) in the UI, repaints the grid
    }
  }

  /// ONE TICK, orchestrator: game timers run first, then movement.
  /// Separating them keeps the collision/score core (`_advance`) focused.
  void _step() {
    _tickGoldenTimer();
    _advance();
  }

  /// 🌟 Golden TTL: the 3× prize is a limited-time offer. Ignored goldens
  /// quietly despawn into a NORMAL apple — no points, no penalty, and the
  /// cadence moves on (prevents an infinite chain of free goldens).
  void _tickGoldenTimer() {
    if (apple?.isGolden != true) return;
    if (--goldenTicksLeft <= 0) {
      apple = _spawnApple(golden: false);
    }
  }

  /// The movement core: face pending input → advance → collide → eat.
  void _advance() {
    snake.direction = _pending;
    final nextHead = snake.head + snake.direction.delta;

    // ── Collision engine: the two binary death checks ──
    if (_hitsWall(nextHead) || snake.occupies(nextHead)) {
      _setPhase(GamePhase.gameOver); // onTick fires → dialog opens
      return;
    }

    final eaten = apple;
    final ateApple = eaten != null && nextHead == eaten.position;
    snake.move(grow: ateApple);

    if (ateApple) {
      // MIXIN × GOLDEN: base + speed premium + length premium, ×3 if 🌟.
      score += scoreForApple(
            tickMilliseconds: tickMs,
            snakeLength: snake.length,
          ) *
          (eaten.isGolden ? goldenMultiplier : 1);
      _afterAppleEaten(wasGolden: eaten.isGolden);
    }
  }

  /// Every bite: count it → ramp the difficulty curve → spawn the next
  /// fruit. Every 5th apple is GOLDEN.
  void _afterAppleEaten({required bool wasGolden}) {
    applesEaten++;
    if (wasGolden) goldenEaten++;
    tickMs = tickMsForApples(applesEaten, base: baseTickMs); // ⚡ speed up
    apple = _spawnApple();
  }

  bool _hitsWall(Point p) =>
      p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize;

  /// Spawns a fresh apple on a random free cell.
  /// [golden] null → follow the cadence (every 5th); explicit value →
  /// forced (the TTL timer uses `false` to break golden chains).
  Apple _spawnApple({bool? golden}) {
    final g = golden ?? ((applesEaten + 1) % 5 == 0);
    goldenTicksLeft = g ? goldenTtlTicks : 0; // ⏳ arm the TTL
    Point p;
    // Keep rolling the dice until the apple lands on an empty cell.
    do {
      p = Point(_rng.nextInt(gridSize), _rng.nextInt(gridSize));
    } while (snake.occupies(p));
    return Apple(p, isGolden: g);
  }
}
