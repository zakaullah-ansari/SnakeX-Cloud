/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — Core game models
/// SYLLABUS: OOP. The class SHAPES are pre-written; the LOGIC is yours.
/// Follow the TODO(STEP x) markers — each is 1–3 lines.
/// ─────────────────────────────────────────────────────────────────────────
library;

/// One cell in the 20×20 matrix. Immutable x/y coordinate.
class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  /// Matrix (row, col) → 1D index for GridView.builder.
  /// TODO(STEP 1): return the row-major index — hint: rows of `columns`
  /// cells sit above us, plus `x` cells into our own row.
  int toIndex(int columns) => 0; // ← replace the 0

  /// Vector addition — one "step" in a Direction.
  /// TODO(STEP 1): return a NEW Point whose x/y are this + delta.
  Point operator +(Point delta) => Point(x, y); // ← currently goes nowhere!

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// The 4 legal moves. Each enum value OWNS its delta vector.
enum Direction {
  up(Point(0, -1)),
  down(Point(0, 1)),
  left(Point(-1, 0)),
  right(Point(1, 0));

  final Point delta;
  const Direction(this.delta);

  /// 180° turns are illegal. Two deltas cancel out if they sum to (0, 0).
  /// TODO(STEP 1): one line, using operator + and == on Point.
  bool isOppositeOf(Direction other) => false;
}

/// The snake = ordered List<Point>, HEAD FIRST.
class Snake {
  static const List<Point> _defaultBody = [
    Point(10, 10),
    Point(9, 10),
    Point(8, 10),
  ];

  final List<Point> body;
  Direction direction;

  Snake({List<Point>? body, this.direction = Direction.right})
      : body = List.of(body ?? _defaultBody);

  Point get head => body.first;
  int get length => body.length;
  bool occupies(Point p) => body.contains(p);

  /// One tick of movement.
  /// TODO(STEP 2): insert (head + direction.delta) at index 0,
  /// then removeLast() — UNLESS [grow] is true (an apple was eaten).
  void move({bool grow = false}) {
    // your 2–3 lines here
  }
}

/// The food target. v2: every 5th apple is GOLDEN (🌟 3× score).
class Apple {
  final Point position;
  final int points;
  final bool isGolden;
  const Apple(this.position, {this.points = 10, this.isGolden = false});
}
