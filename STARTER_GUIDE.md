# 🐍 SnakeX Cloud — STUDENT STARTER GUIDE

Welcome! This repository's **`lib/` folder is YOUR starter kit** — a
fill-in-the-blanks project. The boring boilerplate (UI shell, theme, routes,
login screen, dialogs) is pre-written so you spend all 120 minutes on the
code that *matters for interviews*.

## Setup (5 min — do this BEFORE the workshop if possible)

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate platform folders (android/ios/web) if missing
flutter create .

# 3. Connect your Firebase project (trainer provides the project id)
dart pub global activate flutterfire_cli
flutterfire configure          # generates lib/firebase_options.dart

# 4. Run it! The shell compiles: you'll see the board, a frozen snake
#    and a red dot apple. The logic is YOURS to write (see the map below).
flutter run --dart-define=GROQ_API_KEY=<trainer-gives-key-in-class>
```

> **No laptop? No Firebase? DartPad fallback:** Steps 1–6 (models, loop,
> painters, AI call) are pure Flutter/Dart — paste `lib/models`, `lib/mixins`,
> `lib/game`, `lib/painting` + `lib/screens/game_screen.dart` into
> [dartpad.dev](https://dartpad.dev) and add `http` via the package menu.
> Firebase steps are watched live on the trainer's screen.

## 🗺️ TODO Map — your 120 minutes

| STEP | File (all under `lib/`) | You write | Syllabus topic | ⏱ block |
|-----:|-------------------------|-----------|----------------|---------|
| 1 | `models/game_models.dart` | `toIndex`, `operator +`, `isOppositeOf` | OOP models | B1 |
| 2 | `models/game_models.dart` | `Snake.move()` | OOP · list ops | B1 |
| 3 | `game/snake_game_controller.dart` | `changeDirection()` | input & validation | B1 |
| 4 | `game/snake_game_controller.dart` | `start()` — the tick loop | async `Future.delayed` | B2 |
| 5 | `game/…controller.dart` + `mixins/score_calculation_mixin.dart` | `_advance()` movement core + 3 mixin lines | mixins · OOP | B2 |
| 6 | `painting/apple_painter.dart` | 4 canvas layers | CustomPainter | B2 |
| 7 | `services/ai_trivia_service.dart` | the ~10-line POST | REST API + try/catch | B2 |
| 8 | `services/leaderboard_service.dart` + `widgets/leaderboard_panel.dart` | query stream + StreamBuilder | Firestore streams | B3 |
| 9 ⭐ | `painting/apple_painter.dart` | golden palette + glints (`golden` flag) | CustomPainter polish | bonus |

Everything else — `main.dart`, `screens/game_screen.dart`,
`screens/login_screen.dart`, `painting/snake_segment_painter.dart`,
`services/sfx_service.dart` — is marked **[PRE-WRITTEN]**. Read it,
ask questions about it, but don't rebuild it.

## ⭐ gameplay you get for free (pre-written plumbing)

Tap/swipe-to-start overlay · pause button + overlay · **auto-pause when you
switch apps** · haptic buzz on every bite and on death · **8-bit sound
effects** (chomp / golden arpeggio / death slide / start chime) with a mute
toggle · progressive speed-up (`×1.0 → ×2.0` chip in the HUD) · **golden
apples every 5th spawn (3× score) that despawn after 30 ticks** — watch the
⭐ countdown chip and the blink when time runs out · NEW SESSION BEST
callout · your row highlighted on the leaderboard.

**Stretch challenges (own time):**
- **#10 · DJ Snake:** pitch-shift the chomp as the game speeds up —
  `await _player.setPlaybackRate(_game.speedRatio)` inside `SfxService`.
- **#11 · Personal best forever:** persist it with the `shared_preferences`
  package, load it in `initState`.

## ✅ How to know you're winning

- **Red → Green spec:** `flutter test` runs `test/workshop_logic_test.dart`
  — several specs FAIL on this starter and turn green as you finish STEPS 1–5
  (the v2 difficulty/lifecycle specs are green out of the box — free wins).
- **Definition of Done:** tap to start · the snake moves and turns · eating
  apples grows it and raises your score with bonuses · the game **speeds up**
  every 4 apples · a **golden snake-bait apple** pays 3× · **pause works**
  (even when a call comes in) · walls kill you · game over shows the
  **AI roast** + run stats · your score appears on the **class leaderboard**
  within a second — with your row highlighted. Screenshot it, then write
  your 3 resume bullets from `WORKSHOP.md` Part 6. 🚀

Stuck? The trainer's answer key lives in `solution/lib/` — peeking is
allowed; *understanding why it works* is the actual exam.
