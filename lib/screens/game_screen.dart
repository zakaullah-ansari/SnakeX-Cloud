import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback — pure Flutter, no package

import '../game/snake_game_controller.dart';
import '../models/game_models.dart';
import '../painting/apple_painter.dart';
import '../painting/snake_segment_painter.dart';
import '../services/ai_trivia_service.dart';
import '../services/leaderboard_service.dart';
import '../services/sfx_service.dart';

/// [PRE-WRITTEN UI SHELL v3 — do not edit during the workshop]
/// All layout, overlays, gestures, haptics, SFX, GridView and dialogs are
/// wired. Your TODOs live in the LOGIC files (search "TODO(STEP").
///
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  static const int grid = SnakeGameController.gridSize;

  late final SnakeGameController _game;
  final _trivia = AiTriviaService();
  final _sfx = SfxService(); // 🔊 v3: 8-bit juice

  int _tickCount = 0; // drives the apple pulse
  int _lastScore = 0; // for chomp haptics/sfx
  int _lastGolden = 0; // detects golden bites specifically
  int _sessionBest = 0;
  bool _newBest = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← auto-pause hook
    _game = SnakeGameController(onTick: _handleTick);
    // autoBegin: false → the board sits behind the TAP TO START overlay
    // until the player's FIRST swipe (no unfair instant deaths).
    _game.start(autoBegin: false);
  }

  void _handleTick() {
    if (!mounted) return;
    setState(() {
      _tickCount++;
      if (_game.score > _lastScore) {
        _lastScore = _game.score;
        if (_game.goldenEaten > _lastGolden) {
          _lastGolden = _game.goldenEaten;
          HapticFeedback.heavyImpact(); // 🌟 big prize, big buzz
          _sfx.golden(); // 4-note arpeggio
        } else {
          HapticFeedback.lightImpact(); // 🍎 chomp
          _sfx.chomp();
        }
      }
    });
    if (_game.isGameOver && !_dialogShown) {
      HapticFeedback.mediumImpact(); // 💀 death rattle
      _sfx.death(); // descending slide
      _newBest = _game.score > _sessionBest;
      _sessionBest = max(_sessionBest, _game.score);
      _showGameOver();
    }
  }

  /// ⏸ Production UX: a phone call or app switch PAUSES the arcade —
  /// the snake must never die because life interrupted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _game.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.dispose(); // stop the tick loop — no dangling async work
    _sfx.dispose();
    super.dispose();
  }

  /// Launch a run: the begin chime doubles as the web-audio "unlock" gesture.
  void _beginRun() {
    _game.begin();
    _sfx.begin();
  }

  /// First touch both LAUNCHES the run (ready → playing) and steers.
  void _steer(Direction dir) {
    if (_game.phase == GamePhase.ready) _beginRun();
    _game.changeDirection(dir); // 180° swipes filtered by the controller
  }

  // ── GAME OVER: score → cloud, run-stats + AI intermission → screen ─────
  Future<void> _showGameOver() async {
    _dialogShown = true;
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : 'Snake-${(user?.uid ?? 'anon').substring(0, 4)}';

    await LeaderboardService.submitScore(
      uid: user?.uid ?? 'anonymous',
      name: name,
      score: _game.score,
    );
    final triviaFuture = _trivia.fetchGameOverTrivia(_game.score);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('GAME OVER 💀'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_game.score} pts',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            Text(_game.grade(_game.score)), // ← mixin method, live in the UI
            if (_newBest)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('🎉 NEW SESSION BEST!',
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 8),
            // v2 run stats: apples · goldens · top speed
            Text(
              '🍎 ${_game.applesEaten}  ·  🌟 ${_game.goldenEaten}  ·  '
              '⚡ ×${_game.speedRatio.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('🎙️ AI INTERMISSION',
                style: TextStyle(letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: triviaFuture,
              builder: (context, snap) => snap.hasData
                  ? Text(snap.data!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic))
                  : const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
            child: const Text('Leaderboard 🏆'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _game.reset();
                _lastScore = 0;
                _lastGolden = 0;
                _dialogShown = false;
              });
              _game.start(); // replay auto-begins — revenge is instant
              _sfx.begin();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  // ── CELL FACTORY: decide what each of the 400 matrix cells renders ─────
  Widget _buildCell(int index) {
    final cell = Point(index % grid, index ~/ grid); // row-major decode
    final apple = _game.apple;

    // APPLE (red) or GOLDEN APPLE (🌟 every 5th, 3×, TTL-limited) —
    // flashing glow via AnimatedContainer + hand-painted fruit.
    if (apple != null && cell == apple.position) {
      final glow = apple.isGolden ? Colors.amberAccent : Colors.redAccent;
      // v3 urgency telegraph: in its last 10 ticks the golden BLINKS off
      // every other frame and breathes twice as fast — grab it NOW.
      final urgent = apple.isGolden && _game.goldenTicksLeft <= 10;
      final glowOn = _tickCount.isEven || (apple.isGolden && !urgent);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          boxShadow: glowOn
              ? [
                  BoxShadow(
                    color: glow.withOpacity(0.7),
                    blurRadius: apple.isGolden ? 20 : 14,
                    spreadRadius: apple.isGolden ? 2 : 1,
                  )
                ]
              : const [],
        ),
        child: CustomPaint(
          painter: ApplePainter(
            pulse: apple.isGolden ? (_tickCount % 3) / 3 : (_tickCount % 6) / 6,
            golden: apple.isGolden,
          ),
        ),
      );
    }

    // SNAKE → hand-drawn rounded segment (head gets eyes).
    if (_game.snake.occupies(cell)) {
      return CustomPaint(
        painter: SnakeSegmentPainter(isHead: cell == _game.snake.head),
      );
    }

    // FLOOR → retro checkerboard.
    return Container(
      color: (cell.x + cell.y).isEven
          ? const Color(0xFF10161E)
          : const Color(0xFF0C1117),
    );
  }

  Widget _hudChip(IconData icon, String label, {bool active = false}) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.amber.shade700 : Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );

  Widget _overlay({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: const Color(0xFF7CFC00)),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // MediaQuery — the board adapts to the SHORTEST side and stays square.
    final boardSize = MediaQuery.of(context).size.shortestSide * 0.92;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SnakeX Cloud'),
        actions: [
          // 🔊 v3 SFX mute toggle
          IconButton(
            tooltip: _sfx.muted ? 'Unmute SFX' : 'Mute SFX',
            icon: Icon(_sfx.muted ? Icons.volume_off : Icons.volume_up),
            onPressed: () => setState(() => _sfx.muted = !_sfx.muted),
          ),
          // ⏸ pause / ▶ resume
          IconButton(
            tooltip: _game.isPaused ? 'Resume' : 'Pause',
            icon: Icon(_game.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () =>
                _game.isPaused ? _game.resume() : _game.pause(),
          ),
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── HUD: score pop + speed / length / best chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score POPS on every bite (AnimatedSwitcher + ValueKey).
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      'SCORE ${_game.score}',
                      key: ValueKey(_game.score),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          _hudChip(
                              Icons.speed,
                              '×${_game.speedRatio.toStringAsFixed(1)}',
                              active: _game.tickMs <
                                  SnakeGameController.defaultTickMs),
                          // v3: live golden-TTL countdown (only while one is out)
                          if (_game.apple?.isGolden ?? false)
                            _hudChip(
                                Icons.star_rounded,
                                '${_game.goldenTicksLeft}',
                                active: _game.goldenTicksLeft <= 10),
                          _hudChip(
                              Icons.straighten,
                              '+${_game.lengthBonus(_game.snake.length)}',
                              active:
                                  _game.lengthBonus(_game.snake.length) > 2),
                          _hudChip(Icons.military_tech, '$_sessionBest',
                              active: _newBest),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── THE BOARD: swipe surface + 20×20 matrix + OVERLAY STACK ──
            GestureDetector(
              onVerticalDragUpdate: (d) {
                if (d.delta.dy.abs() > 2) {
                  _steer(d.delta.dy > 0 ? Direction.down : Direction.up);
                }
              },
              onHorizontalDragUpdate: (d) {
                if (d.delta.dx.abs() > 2) {
                  _steer(d.delta.dx > 0 ? Direction.right : Direction.left);
                }
              },
              onTap: () {
                if (_game.phase == GamePhase.ready) _game.begin();
                if (_game.isPaused) _game.resume();
              },
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Board (border flashes red at the crash site 💥)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _game.isGameOver
                              ? Colors.redAccent
                              : const Color(0xFF2ECC71),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (_game.isGameOver
                                    ? Colors.redAccent
                                    : const Color(0xFF2ECC71))
                                .withOpacity(0.35),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: grid,
                        ),
                        itemCount: grid * grid,
                        itemBuilder: (context, index) => _buildCell(index),
                      ),
                    ),

                    // v2 OVERLAYS (Stack layer 2) — mirror the phase machine
                    if (_game.phase == GamePhase.ready)
                      _overlay(
                        icon: Icons.play_circle_outline,
                        title: 'SNAKEX CLOUD',
                        subtitle: _sessionBest > 0
                            ? 'Swipe or tap to begin · best $_sessionBest'
                            : 'Swipe or tap to begin 🐍',
                        onTap: _beginRun,
                      ),
                    if (_game.isPaused)
                      _overlay(
                        icon: Icons.pause_circle_outline,
                        title: 'PAUSED',
                        subtitle: 'Tap to resume',
                        onTap: _game.resume,
                      ),
                  ],
                ),
              ),
            ),

            // ── D-PAD for web/desktop (and DartPad demos) ──
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  _padButton(Icons.keyboard_arrow_up, Direction.up),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _padButton(Icons.keyboard_arrow_left, Direction.left),
                      const SizedBox(width: 56),
                      _padButton(Icons.keyboard_arrow_right, Direction.right),
                    ],
                  ),
                  _padButton(Icons.keyboard_arrow_down, Direction.down),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _padButton(IconData icon, Direction dir) => IconButton(
        iconSize: 34,
        visualDensity: VisualDensity.compact,
        onPressed: () => _steer(dir),
        icon: Icon(icon),
      );
}
