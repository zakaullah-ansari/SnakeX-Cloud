import 'dart:async';
import 'dart:math';

import '../mixins/score_calculation_mixin.dart';
import '../models/game_models.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — SnakeGameController (pure Dart game brain)
/// SYLLABUS: async (Future.delayed loop), mixins, OOP composition.
/// v3: lifecycle machine, difficulty curve, golden TTL & step orchestrator
/// are PRE-WRITTEN plumbing; YOU write: input validation, the pause-aware
/// loop, and the movement/collision CORE (`_advance`).
/// ─────────────────────────────────────────────────────────────────────────

/// [PRE-WRITTEN] Pure difficulty curve: every 4 apples, tick −15ms (floor 90).
/// Pure function → unit-testable (see test/workshop_logic_test.dart).
int tickMsForApples(int applesEaten, {int base = 180}) {
  final floor = base < 90 ? base : 90;
  final t = base - (applesEaten ~/ 4) * 15;
  return t < floor ? floor : t;
}

/// [PRE-WRITTEN] The UI's overlay Stack mirrors these phases 1:1.
enum GamePhase { ready, playing, paused, gameOver }

class SnakeGameController with ScoreCalculationMixin {
  static const int gridSize = 20;
  static const int defaultTickMs = 180;
  static const int goldenMultiplier = 3; // golden apples pay 3×

  /// 🌟 Golden apples vanish after this many ticks uneaten (30 ticks ≈ 5.4s
  /// at start speed — LESS as the game accelerates. Grab them fast!)
  static const int goldenTtlTicks = 30;

  final void Function() onTick; // → setState() in the widget layer
  final Random _rng = Random();
  final int baseTickMs;

  late Snake snake;
  Apple? apple;

  int score = 0;
  int applesEaten = 0;
  int goldenEaten = 0;
  int tickMs = defaultTickMs;

  /// [PRE-WRITTEN] Ticks left before the current golden despawns.
  /// The HUD countdown chip and the blinking urgency read this.
  int goldenTicksLeft = 0;

  GamePhase _phase = GamePhase.ready;
  GamePhase get phase => _phase;
  bool get isGameOver => _phase == GamePhase.gameOver;
  bool get isPlaying => _phase == GamePhase.playing;
  bool get isPaused => _phase == GamePhase.paused;

  /// HUD speed readout: 1.0× → 2.0× as the curve ramps.
  double get speedRatio => defaultTickMs / tickMs;

  /// Buffered input prevents 180° self-collision on fast double-swipes.
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
    _phase = GamePhase.ready;
  }

  // [PRE-WRITTEN] v2 lifecycle controls — the pause overlay's best friends.
  void begin() => _setPhase(GamePhase.playing);
  void pause() {
    if (isPlaying) _setPhase(GamePhase.paused);
  }

  void resume() {
    if (isPaused) _setPhase(GamePhase.playing);
  }

  void dispose() => _phase = GamePhase.gameOver;

  void _setPhase(GamePhase p) {
    if (_phase == p) return;
    _phase = p;
    onTick();
  }

  /// TODO(STEP 3): ignore illegal 180° turns (isOppositeOf), otherwise
  /// store dir in `_pending` (NOT directly into snake.direction — why?)
  void changeDirection(Direction dir) {
    // your 1–2 lines here
  }

  /// ── THE GAME LOOP (pause-aware) ─────────────────────────────────────
  /// TODO(STEP 4): 6 lines —
  ///   if (autoBegin) begin();
  ///   while (!isGameOver) {
  ///     await Future.delayed(Duration(milliseconds: tickMs));
  ///     if (!isPlaying) continue;   // overlays freeze the sim
  ///     _step();
  ///     onTick();
  ///   }
  /// DISCUSS: why Future.delayed inside a while-loop instead of
  /// Timer.periodic? (hint: cancellation & readability)
  Future<void> start({bool autoBegin = true}) async {
    // your ~6 lines here
  }

  /// [PRE-WRITTEN] ONE TICK, orchestrator: timers first, then movement.
  void _step() {
    _tickGoldenTimer(); // 🌟 countdown — blinks & despawns, no score change
    _advance();
  }

  /// [PRE-WRITTEN] 🌟 Golden TTL: ignored goldens quietly despawn into a
  /// NORMAL apple — no points, no penalty, cadence moves on (prevents an
  /// infinite chain of free goldens).
  void _tickGoldenTimer() {
    if (apple?.isGolden != true) return;
    if (--goldenTicksLeft <= 0) {
      apple = _spawnApple(golden: false);
    }
  }

  /// The movement core — TODO(STEP 5), ~12 lines:
  ///   1. snake.direction = _pending
  ///   2. nextHead = snake.head + snake.direction.delta
  ///   3. dead if _hitsWall(nextHead) or snake.occupies(nextHead)
  ///      → _setPhase(GamePhase.gameOver); RETURN immediately
  ///   4. final eaten = apple;
  ///      snake.move(grow: nextHead == eaten?.position)
  ///   5. if an apple WAS eaten:
  ///        score += scoreForApple(tickMilliseconds: tickMs,
  ///          snakeLength: snake.length)
  ///          * (eaten.isGolden ? goldenMultiplier : 1)   ← YOUR MIXIN × 🌟
  ///        then _afterAppleEaten(wasGolden: eaten.isGolden);
  void _advance() {
    // your ~12 lines here
  }

  // ── PRE-WRITTEN helpers ────────────────────────────────────────────────

  /// Every bite: count it → ramp difficulty → spawn next fruit.
  void _afterAppleEaten({required bool wasGolden}) {
    applesEaten++;
    if (wasGolden) goldenEaten++;
    tickMs = tickMsForApples(applesEaten, base: baseTickMs); // ⚡ speed up
    apple = _spawnApple();
  }

  bool _hitsWall(Point p) =>
      p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize;

  /// Every 5th apple is GOLDEN by cadence; [golden] explicitly set overrides
  /// (the TTL timer passes `false` to break golden chains).
  Apple _spawnApple({bool? golden}) {
    final g = golden ?? ((applesEaten + 1) % 5 == 0);
    goldenTicksLeft = g ? goldenTtlTicks : 0; // ⏳ arm the TTL
    Point p;
    do {
      p = Point(_rng.nextInt(gridSize), _rng.nextInt(gridSize));
    } while (snake.occupies(p));
    return Apple(p, isGolden: g);
  }
}
