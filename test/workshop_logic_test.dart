/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · Red→Green Workshop Spec
/// These tests are the machine-checkable version of your TODO map.
/// On the starter kit several FAIL (that's normal!). As you complete the
/// STEPs, watch them turn green one by one:  flutter test
/// ─────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

import 'package:snakex_cloud/game/snake_game_controller.dart';
import 'package:snakex_cloud/models/game_models.dart';

void main() {
  group('STEP 1 · matrix math & OOP models', () {
    test('Point.toIndex is row-major: seat #143 = row 7, col 3', () {
      expect(const Point(3, 7).toIndex(20), 143);
    });
    test('operator + steps exactly one cell in a direction', () {
      expect(const Point(10, 10) + Direction.up.delta, const Point(10, 9));
    });
    test('180° turns are detected (and 90° turns are legal)', () {
      expect(Direction.up.isOppositeOf(Direction.down), isTrue);
      expect(Direction.up.isOppositeOf(Direction.left), isFalse);
    });
  });

  group('STEP 2 · snake movement = list surgery', () {
    test('move() shifts head forward and the tail follows', () {
      final s = Snake();
      s.move();
      expect(s.head, const Point(11, 10));
      expect(s.length, 3);
    });
    test('grow keeps the tail (an apple was eaten)', () {
      final s = Snake();
      s.move(grow: true);
      expect(s.length, 4);
    });
  });

  group('STEP 5 · ScoreCalculationMixin', () {
    test('speed bonus maps 250ms→0 and 50ms→20', () {
      final c = SnakeGameController(onTick: () {});
      expect(c.speedBonus(250), 0);
      expect(c.speedBonus(50), 20);
    });
    test('length bonus pays +1 per 5 body cells', () {
      final c = SnakeGameController(onTick: () {});
      expect(c.lengthBonus(14), 2);
      expect(
        c.scoreForApple(tickMilliseconds: 250, snakeLength: 15),
        10 + 0 + 3, // base + speed + length
      );
    });
  });

  group('STEP 4+5 · the tick loop & collision engine', () {
    test('driving blind into the wall ends the game', () async {
      final c = SnakeGameController(onTick: () {}, baseTickMs: 1);
      await c.start().timeout(const Duration(seconds: 5));
      expect(c.isGameOver, isTrue);
    });
  });

  group('v2 · difficulty curve & lifecycle state machine', () {
    test('tickMsForApples ramps −15ms per 4 apples, floor 90', () {
      expect(tickMsForApples(0), 180);
      expect(tickMsForApples(7), 180); // 7 apples → still 0 ramps (~/4)
      expect(tickMsForApples(8), 150); // 8 apples → 2 ramps
      expect(tickMsForApples(999), 90); // clamped at the floor
    });

    test('begin / pause / resume transitions are legal', () {
      final c = SnakeGameController(onTick: () {})..begin();
      expect(c.isPlaying, isTrue);
      c.pause();
      expect(c.isPaused, isTrue);
      c.resume();
      expect(c.isPlaying, isTrue);
    });

    test('pause is ignored unless playing (no pause-before-begin bug)', () {
      final c = SnakeGameController(onTick: () {})..pause();
      expect(c.isPaused, isFalse);
      expect(c.phase, GamePhase.ready);
    });
  });
}
