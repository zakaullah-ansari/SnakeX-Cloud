/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · Core game models
/// SYLLABUS: OOP — classes, enhanced enums, immutability, operator overloads
/// ─────────────────────────────────────────────────────────────────────────
library;

/// One cell in the 20×20 matrix. An immutable value object:
/// two Points with the same x/y are EQUAL (== overridden).
class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  /// Matrix (row, col) → 1D index used by GridView.builder.
  /// Row-major order: index = (row × columns) + column.
  int toIndex(int columns) => y * columns + x;

  /// Vector addition — how the head "steps" one cell in a Direction.
  Point operator +(Point delta) => Point(x + delta.x, y + delta.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// The 4 legal moves. Each enum value OWNS its delta vector —
/// moving the snake never needs a switch statement.
enum Direction {
  up(Point(0, -1)),
  down(Point(0, 1)),
  left(Point(-1, 0)),
  right(Point(1, 0));

  final Point delta;
  const Direction(this.delta);

  /// 180° turns are illegal: reversing into your own neck is instant death.
  bool isOppositeOf(Direction other) =>
      delta + other.delta == const Point(0, 0);
}

/// The snake = an ordered List<Point>, HEAD FIRST.
/// A move is just: insert a new head, drop the tail. No physics. No frames.
class Snake {
  static const List<Point> _defaultBody = [
    Point(10, 10),
    Point(9, 10),
    Point(8, 10),
  ];

  final List<Point> body;
  Direction direction;

  Snake({List<Point>? body, this.direction = Direction.right})
      // List.of() → a MUTABLE copy (a const list would throw on insert!).
      : body = List.of(body ?? _defaultBody);

  Point get head => body.first;
  int get length => body.length;
  bool occupies(Point p) => body.contains(p);

  /// One tick of movement. When [grow] is true we keep the tail
  /// (an apple was just eaten), so the snake gets 1 cell longer.
  void move({bool grow = false}) {
    body.insert(0, head + direction.delta);
    if (!grow) body.removeLast();
  }
}

/// The food target, re-spawned on a random free cell after every bite.
/// v2: every 5th apple is GOLDEN (🌟 3× score) — rendered amber on canvas.
class Apple {
  final Point position;
  final int points;
  final bool isGolden;
  const Apple(this.position, {this.points = 10, this.isGolden = false});
}
