# 🐍☁️ SnakeX Cloud — The 120-Minute Flutter × Firebase × AI Workshop

**Audience:** 3rd-year engineering students, complete Flutter beginners
**Format:** Hands-on, fill-in-the-blanks starter kit (repo root `lib/`) + trainer answer key (`solution/`)
**Outcome (SMART):** Every student ships a playable, cloud-synced, AI-enhanced arcade game and leaves with 3 resume-ready bullet points.

---

# PART 0 · Design Reasoning (Chain-of-Thought, executed explicitly)

> These are the four architectural decisions the entire workshop hangs on.
> Trainers: teaching the *reasoning* is what separates "code along" from
> "mentorship". Students: this is how you answer "why did you build it
> this way?" in an interview.

## Step 1 — Grid Coordinate & State Data Modeling

**Decision:** One source of truth, three pure-Dart shapes — no physics engine, no frame ticker, no game library.

| Question a beginner asks | Answer |
|---|---|
| How do I store a 20×20 board? | You **don't**. The board is *virtual*: `GridView.builder` asks "what is at index `i`?" and we decode `i` → `Point(i % 20, i ~/ 20)` on demand. Nothing to allocate, nothing to sync. |
| Where is the snake stored? | `List<Point>` (head-first). A move = `insert(0, nextHead)` + `removeLast()`. Two list operations per tick = the entire simulation. |
| Where is the food? | A single `Apple(Point position)`. Respawn = roll a random `Point` in `[0,19]²`, retry while `snake.occupies(p)`. |
| What's the state of the whole game? | ~6 fields: `snake`, `apple`, `score`, `isGameOver`, `tickMs`, `_pending` direction. Fits on one slide. |

**Why this survives beginners:** movement is *discrete* (one cell per tick), so there is no floating-point math, no deltatime, no collision meshes — just integer grid coordinates and `==` on a `Point`. The `Point` value-object (with `operator +` and `==`) is also the perfect, non-contrived vehicle for teaching **OOP operators, immutability and equality** on day one. Known simplification (mentioned as a stretch note): `occupies(nextHead)` uses the pre-move body, so stepping into the cell the tail *just vacated* counts as death — stricter than the Nokia original, safer to teach, one-line fix for advanced students.

## Step 2 — AI REST API Integration Architecture

**Decision:** A hosted LLM (Groq free tier, OpenAI-compatible REST) called with **one `http.post` + `jsonDecode` — ~10 lines inside a `try/catch`. Zero native ML SDKs, zero on-device inference, zero model downloads.**

```text
Flutter app ──HTTP POST { score }──▶ api.groq.com (Llama 3.1) ──"1-sentence roast"──▶ AlertDialog
```

Design rules we verify before class:
1. **Text in → text out.** The prompt is a single templated string; the response is parsed with `dart:convert`. Students already know everything they need.
2. **The AI key is never in source control.** Injected via `flutter run --dart-define=GROQ_API_KEY=…` and read with `String.fromEnvironment`. This is itself a teachable industry practice.
3. **Third-party AI is treated as unreliable on purpose.** `try/catch` returns a canned roast on failure, and an empty key triggers `offlineRoasts` — the workshop *never blocks* on hotel Wi-Fi, quota limits, or revoked keys. That's not just robustness; it's the **exception-handling syllabus item demonstrated in production context**.
4. **Zero native code.** `http` is pure Dart → the same code runs on Android, iOS, web and DartPad.

## Step 3 — Syllabus Mapping Verification (audit trace)

Every syllabus line was traced to ≥1 concrete artifact before freezing the curriculum (full table in Part 2). Spot-checks of the tricky ones:

- **Mixins** → `ScoreCalculationMixin` is *mixed into* `SnakeGameController` (`with`), then consumed in the UI HUD (`_game.lengthBonus(...)`) — students SEE the mixin flowing from game logic into pixels.
- **CustomPainter** → not a decorative demo: `ApplePainter` (glow layers) and `SnakeSegmentPainter` (rounded cells) are the *only* way anything is drawn on the board.
- **Streams** → two different flavors: `authStateChanges()` (state stream at app root) and Firestore `.snapshots()` (query stream feeding `StreamBuilder`+`ListView.builder`).
- **Async** → two different flavors: self-rescheduling `Future.delayed` game loop and `await http.post` network call, contrasted explicitly in Block 2.
- **Exception handling** → three distinct caught failure domains: auth (`on FirebaseAuthException`), database (`submitScore` try/catch), AI (`try/catch` with graceful fallback).

**Coverage: 19/19 syllabus items mapped** (see Part 2 table — no orphans).

## Step 4 — Time & Cognitive Load Optimization

**Decision: pre-write the *plumbing*, live-code the *story*.** Cognitive load theory for 120 minutes with total beginners: every minute spent on SDK setup or theme boilerplate is a minute stolen from the concepts they must internalize. So:

| Pre-written in root `lib/` (walkthrough only) | Live-coded by students (STEPS 1–8) |
|---|---|
| pubspec, theme, routes, `AuthGate` | `Point` math, `Snake.move` (OOP) |
| Login screen (auth walkthrough in Block 3) | Direction buffer + swipe handling |
| GameScreen shell: AppBar, HUD, GridView, dialogs, D-pad | The `Future.delayed` tick loop |
| `SnakeSegmentPainter` (read-by-analogy demo) | Collision engine + `scoreForApple` via mixin |
| `submitScore` (CREATE of CRUD pre-wired) | `ApplePainter` 4 canvas layers |
| Game-over FutureBuilder scaffold | The 10-line AI POST · the top-10 query stream + StreamBuilder |

The 120 minutes decompose into **3 blocks of escalating dopamine** (Part 4):
B1 *it renders & reacts* → B2 *it plays & paints & talks back* → B3 *it's live on the cloud & on my CV*.

Risks engineered around: SDK setup (pre-class checklist + DartPad fallback), Firebase project sharing (one class project, trainer distributes config), AI key quota (offline roasts), pacing (answer key in `solution/` = trainer can `git checkout` any step live to un-stick the room).

---
---

# PART 1 · Final Project Concept & Elevator Pitch

**Name:** 🐍☁️ **SnakeX Cloud** — *"The Nokia classic, rebuilt for the cloud-native, AI-native era."*

**Elevator pitch (2 sentences):**
SnakeX Cloud is a retro 20×20 arcade snake that pairs pixel-perfect discrete grid movement and hand-painted glowing canvas graphics with a **real-time global Firestore leaderboard** — and after every run, an **AI intermission host** (Llama 3.1 over a plain REST call) delivers a personalized one-liner: retro trivia if you're good, a roast if you're not. It's the full modern product loop — gesture UI → ephemeral state → stream-driven cloud sync → third-party AI — compressed into one game a beginner can build in two hours.

**Why interviewers lean forward:** Arcade games prove *simulation + rendering* skills; a **live leaderboard** proves you understand *streams, security rules and server timestamps* (not just CRUD); an **AI-over-REST intermission** proves you can integrate, *and safely bound*, a third-party model without exotic SDKs. It's 30 seconds to demo on your phone in an interview lobby — "watch the leaderboard update on their laptop while I play on my phone" is a story no To-Do app clone can tell.

---

# PART 2 · Comprehensive Syllabus-to-Feature Mapping Table

**19 syllabus items → 19+ concrete, verifiable features. Artifacts in parentheses are real files in this repo.**

| # | Syllabus topic | Where it lives in SnakeX Cloud | Exact functional role |
|---|---|---|---|
| 1 | **OOP models** (`Point`, `Snake`, `Direction`, `Apple`) | `models/game_models.dart` | `Point` = immutable value object w/ `operator +`, `==`, matrix→index math; `Direction` = enhanced enum owning delta vectors + `isOppositeOf`; `Snake` = `List<Point>` with head-first `move(grow:)`; `Apple` = position + points. The entire simulation composes these four classes. |
| 2 | **Mixins** | `mixins/score_calculation_mixin.dart` | `SnakeGameController with ScoreCalculationMixin` gains `speedBonus`, `lengthBonus`, `scoreForApple`, `grade` without inheritance; the HUD badge calls `_game.lengthBonus(...)` — mixin output rendered on screen. |
| 3 | **Exception handling** | 3 caught failure domains | Auth: `on FirebaseAuthException` → SnackBar (`login_screen.dart`). DB: `try/catch` in `submitScore` → log & keep playing. AI: `try/catch` → canned roast fallback. Rule taught: *an app degrades, it never crashes*. |
| 4 | **Async — `Future.delayed` game tick** | `game/snake_game_controller.dart` → `start()` | The game loop: `while (!isGameOver) { await Future.delayed(...); _step(); onTick(); }` — self-rescheduling, await-per-tick, no timer bookkeeping. |
| 5 | **Async — http requests** | `services/ai_trivia_service.dart` | `await http.post(...)` + `jsonDecode(response.body)` — the async network half of the async story, contrasted live with the loop in Block 2. |
| 6 | **Stream handling** | 2 stream flavors | App state stream: `FirebaseAuth.instance.authStateChanges()` at root (`main.dart`). Query stream: Firestore `.snapshots()` top-10 (`leaderboard_service.dart`). |
| 7 | **Single-child widgets** | Board & HUD wrappers | `Container` + `Padding` around the arena, `Center` around the app body, `ConstrainedBox` capping login form width. |
| 8 | **Multi-child widgets** (`Column`/`Row`/`Stack`-family) | `game_screen.dart` | `Column` stacks HUD → board → D-pad; `Row` lays out SCORE ↔ power-up badge; dialog `Column` stacks score → grade → AI intermission. |
| 9 | **MediaQuery (adaptive grid)** | `game_screen.dart` build() | `boardSize = MediaQuery.of(context).size.shortestSide * 0.92` — the 20×20 arena stays square on phone, tablet or Chrome tab. |
| 10 | **GridView.builder** | `game_screen.dart` | The 400-cell matrix: `itemCount: 400`, decode `index → Point(index % 20, index ~/ 20)`, factory decides apple / snake / checkerboard floor per cell. `NeverScrollableScrollPhysics` pins it. |
| 11 | **ListView.builder** | `widgets/leaderboard_panel.dart` | Lazy top-10 render: `ListTile` per doc with rank avatar, name, score — scrolls beyond 10 if `limit` is raised. |
| 12 | **Animations (`AnimatedContainer`)** | 2 live sites | Apple cell shadows flash on alternating ticks (breathing glow); HUD bonus badge morphs color when `lengthBonus > 2` — implicit animation, zero `AnimationController` complexity. |
| 13 | **CustomPainter** | `painting/apple_painter.dart`, `painting/snake_segment_painter.dart` | Everything visible on the board is hand-drawn: blurred neon glow + `RadialGradient` apple body + stem + leaf; rounded `RRect` snake segments with head eyes. `shouldRepaint` keeps 399 cells cached. |
| 14 | **Ephemeral state (`setState`)** | `game_screen.dart` | Controller's `onTick` → `setState` → 400 cells re-query the model. Also: `_tickCount` (apple pulse), `_busy` spinner, dialog guard. Frame ticks, grid updates and direction changes are all local widget state. |
| 15 | **Application state (auth & profile)** | `main.dart` → `AuthGate` | "Who am I?" is app-wide: one root `StreamBuilder<User?>` swaps LoginScreen ↔ GameScreen on sign-in/out. Students articulate the rule: *lives for one screen? setState. Lives across screens? state belongs above.* |
| 16 | **Explicit route navigation** | `main.dart` routes table | Named routes `/`, `/game`, `/leaderboard`; `Navigator.pushNamed` from AppBar trophy and game-over dialog; sign-out pops back through the gate. |
| 17 | **Firebase Authentication** | `screens/login_screen.dart` | Anonymous one-tap login + email/password sign-in/register through one shared `_run()` wrapper; all failures surfaced as SnackBars. |
| 18 | **Cloud Firestore (real-time CRUD streams)** | `services/leaderboard_service.dart` + `firestore.rules` | **C:** `.add({uid,name,score,serverTimestamp})`. **R:** ordered/limit `.snapshots()` stream (live!). **U/D:** stretch exercise (delete own scores w/ rules guard). Rules enforce auth, ownership & integer score range. |
| 19 | **REST API integration (10–12 line POST)** | `services/ai_trivia_service.dart` | `http.post` to Groq (OpenAI-compatible; Gemini URL swappable) with Bearer key via `--dart-define`, JSON body `{model, messages:[{prompt with score}]}`, parse `choices[0].message.content`, render via `FutureBuilder` in the game-over dialog. |

**Audit result: 19/19 items covered, 0 orphans, every item has a compile-able artifact in `solution/`.**

---

# PART 3 · Deep-Dive Concept Analogy Breakdown

## 3.1 Grid Matrix Array — `GridView.builder` is a theater seating chart 🎭

**Beginner analogy:** A theater with 400 seats in 20 rows doesn't keep 400 *people objects*; it keeps a numbering system. Usher asks: "seat #143?" → row `143 ~/ 20 = 7`, seat-in-row `143 % 20 = 3`. `GridView.builder` is that usher: it calls your `itemBuilder(index)` *on demand*, and you decode the seat number. The snake and apple are VIPs "sitting" in seats — you check each seat number against their positions.

**Production mental model:** *Projection over storage.* The board is a pure function `f(index) → Widget` over tiny canonical state (`List<Point>` + one `Point`). Storing a 20×20 array of cell-objects would be denormalized state — a classic bug farm (two sources of truth drifting apart). Flutter's `*.builder` family IS projection-on-demand; this pattern reappears in every feed, calendar, and map-tile app.

## 3.2 Game Loop Ticks — `Future.delayed` vs `setState` ⏲️🔔

**Beginner analogy:** A kitchen. `await Future.delayed(tick)` is the **chef's kitchen timer**: *"wait 180 ms, then cook the next step."* `setState` is the **order bell**: *"the plate changed — waiter, show the dining room."* One schedules *time*; the other announces *change*. Confusing them (calling `setState` to "wait", or delaying to "redraw") is the #1 beginner bug.

**Production mental models:**
- `Future.delayed` in a `while` loop = **cooperative async loop**. Simple, sequential, self-canceling when the condition flips (`isGameOver`). Perfect when ticks must not overlap.
- `Timer.periodic` = **metronome** — fires regardless of whether the last tick finished; you own `cancel()`. Used for clocks, polling.
- Engine route (Flame/`Ticker`) = **vsync-coupled fixed timestep** — what real games use; our loop is its legible 4-line cousin. Telling students the *upgrade path exists* is what makes the analogy stick.

## 3.3 `StreamBuilder` vs `FutureBuilder` 🍕📬

**Beginner analogy:** `FutureBuilder` is **pizza delivery** — you order once, wait, receive once, transaction over (`get()` = "fetch my profile"). `StreamBuilder` is a **magazine subscription / live score ticker** — you subscribe once and *keep receiving every new edition forever* until you leave (`snapshots()` = every leaderboard change, pushed).

**Production mental model:** One-shot request–response vs **subscription to a changing query**. Firestore's Dart stream is a WebSocket under the hood: the server pushes diffs; there is no refresh button *because there is no polling*. Key interview line: `Future<T>` = *one value later*; `Stream<T>` = *many values over time* — and Flutter mirrors both 1:1 in the widget tree (`snapshot.data` in both builders, but a stream rebuilds *again and again*). Bonus: show `authStateChanges()` — same widget, different stream, proving the pattern generalizes.

## 3.4 `CustomPainter` Canvas Layers 🖌️🎨

**Beginner analogy:** The widget tree is **LEGO** — pre-molded bricks you snap together (`Container`, `Text`, `Icon`). `CustomPainter` is a **blank canvas + paintbrush**: *you* decide where every pixel goes (`drawCircle`, `drawLine`, `drawRRect`), like hand-drawing the sprite instead of buying it. And you paint in **cel-animation layers**: our apple is 4 transparent sheets — glow halo → gradient body → stem → leaf — stacked in paint order (back-to-front, like Photoshop).

**Production mental model:** You escape the retained-mode widget tree into **immediate-mode GPU drawing** for exactly one rectangle. Performance hinge = `shouldRepaint`: returning `old.pulse != pulse` tells the Flutter *compositor* it may re-use 399 cached cells and repaint one — that's how the board flies at 60fps. In industry this is how charts, progress rings, signature pads, syntax-highlighter underlines and custom shaders are built.

---

# PART 4 · 120-Minute Step-by-Step Trainer Execution Agenda

> Run of show. Every segment lists: **live-code target** (search `TODO(STEP n)`), the **aha moment** to land, and the **pitfall** to pre-empt. The answer key (`solution/`) is your escape hatch — project any file if the room stalls >5 min.

**Pre-flight (before students enter):** projector mirroring one device; Firebase project created (Email/Password + Anonymous providers ON); `firestore.rules` deployed; Groq free key ready; starter repo URL + setup checklist sent to the class group. Latecomers or broken SDKs → `git clone` + DartPad fallback (STEPS 1–6 work zero-Firebase).

## ⬛ BLOCK 1 (0–45 min) — "It renders & reacts": Starter Walkthrough, 20×20 Grid & Gestures

| Time | Segment | Do / say | Aha / pitfall |
|---|---|---|---|
| 0–8 | **Cold-open demo** | Play the FINISHED app live: leaderboard on the projector updates *while you die on your phone*; AI roast appears. "You're building this in 112 minutes." | Hook first, syntax later. |
| 8–12 | SMART outcomes + syllabus map | Show Part 2 table (1 min) — "every line of your syllabus is a file you'll touch today." | Students *see* the curriculum fit. |
| 12–20 | Starter tour | `STARTER_GUIDE.md` TODO map; file tree; which files are [PRE-WRITTEN] and why (Part 0, Step 4 rationale). Run the shell: frozen snake + red dot renders. | Pitfall: students editing `game_screen.dart`. Redirect: "your arena is the logic files." |
| 20–35 | **LIVE-CODE STEP 1 + 2 — the matrix & the models** | Whiteboard the seating-chart analogy (3.1). Implement `toIndex` (row-major!), `operator +`, `isOppositeOf`, then `Snake.move` (`insert` + `removeLast`). Hot reload: still frozen — "the theater has seats but no play yet." | Aha: *movement = list surgery.* Pitfall: `y * columns + x` written as `x * columns + y` — draw one row on the board to fix it. |
| 35–45 | **LIVE-CODE STEP 3 — gestures & the direction buffer** | Trace a swipe: `GestureDetector` (pre-wired) → `changeDirection`. Implement it. Demo the 180°-suicide bug *without* the `_pending` buffer (let one student hit it!), then explain buffering. | Aha: *input ≠ intent* — buffer, validate, then apply. Pitfall: opposite-check against `_pending` instead of `snake.direction` reintroduces the bug; show why. |

**Checkpoint 1:** Board renders; swipes change `_pending`; nothing moves yet — *by design.*

## ⬛ BLOCK 2 (45–90 min) — "It plays, paints & talks back": Tick Loop, Collisions, CustomPainter, AI REST

| Time | Segment | Do / say | Aha / pitfall |
|---|---|---|---|
| 45–60 | **LIVE-CODE STEP 4 — the tick loop** | Write the 4-line `start()` live. Two-analogy slide (3.2): kitchen timer vs order bell; `Future.delayed` vs `Timer.periodic` upgrade path to Flame. Hot restart → **the snake crawls.** (Biggest cheer moment of Block 2.) | Aha: async loop *coordinates with* `setState` — neither replaces the other. Pitfall: forgetting `onTick()` → logic runs, screen frozen; the PERFECT teaching bug — let it happen once. |
| 60–70 | **LIVE-CODE STEP 5 — collision engine + the mixin** | The movement core `_advance()`: wall check, self check, `move(grow:)`. Then open the mixin: 3 one-liners (`speedBonus`, `lengthBonus`, `scoreForApple`); wire `score += × golden factor` and watch the HUD badge light up past length 15. (Timers? Already handled by the pre-written `_step` orchestrator — name-drop separation of concerns, move on.) | Aha: *behavior without inheritance* — the controller "plugged in" math. Pitfall: calling `move` before the collision check (snake phases through walls); order matters: **face → predict → validate → move.** |
| 70–80 | **LIVE-CODE STEP 6 — CustomPainter** | First READ `SnakeSegmentPainter` (pre-written) with the LEGO-vs-canvas analogy (3.4); then BUILD `ApplePainter` bottom-up: flat circle → glow (`MaskFilter`) → `RadialGradient` body → stem → leaf. Point at `shouldRepaint` + the pulsing `AnimatedContainer` wrapper (pre-wired). | Aha: paint order = layer stack. Pitfall: drawing outside bounds is silently clipped — teach `center`/`radius` from `size`, never magic pixels. |
| 80–90 | **LIVE-CODE STEP 7 — the 10-line AI POST** | Reveal: "an LLM is an HTTP endpoint." Build `fetchGameOverTrivia` line-by-line (headers → body → decode → `choices[0]`). Kill Wi-Fi mid-demo → fallback roast fires → THAT'S exception handling in production, not a textbook. Mention `--dart-define` key hygiene. | Aha: *AI integration = string in, string out.* Pitfall: hardcoding the key — make it a searchable GitHub horror story in one sentence, move on. |

**Checkpoint 2:** Fully playable offline game with AI intermissions. Students who's behind: DartPad users are level here (Firebase hasn't mattered yet).

## ⬛ BLOCK 3 (90–120 min) — "It's live on the cloud & on my CV": Firestore Leaderboard + Placement Framing

| Time | Segment | Do / say | Aha / pitfall |
|---|---|---|---|
| 90–95 | Auth walkthrough (pre-built) | Narrate `AuthGate` stream + `LoginScreen` `_run()`: one wrapper, three sign-in paths, `on FirebaseAuthException`. Everyone signs in anonymously → "you are now a row in the auth table." | Ephemeral vs application state rule (Part 2, #15) — say it out loud, it's an interview question. |
| 95–110 | **LIVE-CODE STEP 8 — cloud sync & the live leaderboard** | Firebase console tour: the `leaderboard` collection as "cloud spreadsheet." `submitScore` (pre-wired): `.add` + `serverTimestamp` (anti-cheat aside). Students write `topTenStream()` (3 chained calls) + the `StreamBuilder` with 3 states + `ListView.builder` rows. Deploy/verify `firestore.rules`. **THE DEMO:** everyone plays → projector shows all rooms' scores flowing in live. | Aha: `StreamBuilder` = subscription, not request (3.3). Pitfalls: missing index on `orderBy` (console link-click fixes live — show the error→fix loop); rules denial → read the simulator message together. |
| 110–115 | End-to-end victory lap + contrast recap | Play one last full run: swipe → tick loop → painter → death → score **streamed** to cloud → AI roast → leaderboard #1 on projector. Rapid-fire recap against the Part 2 table: "which widget did X?" | Every syllabus item verbally re-anchored to a file they touched. |
| 115–120 | **Resume framing + what's next** | Show Part 6 bullets; each student personalizes numbers (final score, leaderboard rank). Stretch map: `Timer`/Flame upgrade, power-ups (the `AnimatedContainer` badge is the hook), CRUD U/D (delete own scores), web build to impress. Assign: post the game + bullets on LinkedIn, tag the university. | The workshop's last artifact is *career capital*, not code. |

**Definition of done (rubric, 10 pts):** snake moves & turns (2) · grows & scores with mixin bonus (2) · wall/self death (1) · painted apple + pulsing glow (2) · AI line on game over (1) · score visible in class leaderboard <1 s (2).

---

# PART 5 · Complete Production Codebase & Starter Snippets

**Full, compile-ready code ships in this repo:** `solution/lib/` (trainer answer key) and root `lib/` (student starter kit, TODOs 1–8, pre-written shell + red→green `test/`). Below, the four workshop-flagship snippets exactly as productionized in the repo.

### a) `ScoreCalculationMixin` — bonus math, plugged in with `with`
`solution/lib/mixins/score_calculation_mixin.dart`

```dart
/// MIXINS — reusable behavior you plug into any class with `with`.
/// Not a parent class: the controller *mixes in* math superpowers.
mixin ScoreCalculationMixin {
  static const int baseApplePoints = 10;

  /// Faster tick interval ⇒ harder game ⇒ bigger bonus (0–20 pts).
  int speedBonus(int tickMilliseconds) {
    const slowestTick = 250;
    final clamped = tickMilliseconds.clamp(50, slowestTick);
    return ((slowestTick - clamped) / 10).round();
  }

  /// Every 5 body segments adds +1 — long-snake risk pays.
  int lengthBonus(int snakeLength) => snakeLength ~/ 5;

  /// One apple = BASE + speed risk premium + length risk premium.
  int scoreForApple({
    required int tickMilliseconds,
    required int snakeLength,
  }) =>
      baseApplePoints +
      speedBonus(tickMilliseconds) +
      lengthBonus(snakeLength);

  /// End-of-run arcade grade for the game-over dialog.
  String grade(int finalScore) => switch (finalScore) {
        >= 500 => 'S — Arcade Legend 🏆',
        >= 250 => 'A — Pixel Pro ⚡',
        >= 100 => 'B — Solid Snake 🐍',
        _      => 'C — Worm in Training 🌱',
      };
}
```

### b) `ApplePainter` — glowing fruit on the raw canvas
`solution/lib/painting/apple_painter.dart` (the 4-layer core of `paint`)

```dart
class ApplePainter extends CustomPainter {
  final double pulse; // 0.0..1.0 breathing glow, driven by the game tick
  const ApplePainter({this.pulse = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.30;

    // LAYER 1 · neon glow — blurred halo that breathes with the pulse
    canvas.drawCircle(center, radius * (1.35 + 0.20 * pulse), Paint()
      ..color = Colors.redAccent.withOpacity(0.35 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // LAYER 2 · body — radial gradient, top-left highlight = fake 3D
    canvas.drawCircle(center, radius, Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade200, Colors.red.shade800],
        center: const Alignment(-0.35, -0.35),
      ).createShader(Rect.fromCircle(center: center, radius: radius)));

    // LAYER 3 · stem (drawLine) · LAYER 4 · leaf (drawOval) — see repo file
  }

  @override
  bool shouldRepaint(ApplePainter old) => old.pulse != pulse; // 399 cells stay cached
}
```

### c) The 10-line AI REST call — score in, roast out
`solution/lib/services/ai_trivia_service.dart` — key via `--dart-define=GROQ_API_KEY`, never in git.

```dart
Future<String> fetchGameOverTrivia(int score) async {
  try {
    final response = await http.post(                                 // ① one POST
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),   //    OpenAI-compatible
      headers: {'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json'},
      body: jsonEncode({'model': 'llama-3.1-8b-instant', 'messages': [
        {'role': 'user', 'content': 'Give a 1-sentence funny retro '
            'gaming fact or roast for someone who scored $score in Snake.'}
      ]}),
    );
    final data = jsonDecode(response.body);                           // ② one decode
    return data['choices'][0]['message']['content'];                  // ③ one string out
  } catch (_) {
    return 'The AI judge lost signal📡… but $score echoes on.';       // ④ graceful degrade
  }
}
```

### d) Firestore `StreamBuilder` — the live global top 10
`solution/lib/widgets/leaderboard_panel.dart` + stream from `leaderboard_service.dart`

```dart
// THE STREAM — ordered top-10 query; re-emits on EVERY backend change.
Stream<QuerySnapshot<Map<String, dynamic>>> topTenStream() =>
    FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots();

// THE WIDGET — subscription UI, three explicit states.
StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: LeaderboardService.topTenStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return const Text('Leaderboard offline 📡');
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final docs = snapshot.data!.docs;
    return ListView.builder(                          // lazy top-10 list
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final entry = docs[i].data();
        return ListTile(
          leading: CircleAvatar(child: Text('#${i + 1}')),
          title: Text(entry['name'] ?? 'Anonymous Snake'),
          trailing: Text('${entry['score']} pts'),
        );
      },
    );
  },
)
```

**Also in the repo (not repeated here):** full OOP models, the `Future.delayed` controller loop + collision engine, `SnakeSegmentPainter`, login screen (3 auth paths, 1 try/catch wrapper), adaptive `GameScreen` (`MediaQuery`, swipes, `GridView.builder`, game-over `FutureBuilder` dialog), root `AuthGate`, `firestore.rules`, and the complete student starter with `TODO(STEP 1–8)`.

---

# PART 6 · Resume-Ready Student Bullet Points

> Paste-ready. Rule given to students: keep the verbs, swap in YOUR numbers (final score, leaderboard rank, bugs fixed live). Each bullet answers an interviewer's silent question.

1. **"Can you build real UI + state?"** — *Engineered a cross-platform Flutter/Dart arcade game rendering a 20×20 matrix with `GridView.builder` and GPU-accelerated `CustomPainter` graphics (layered glow, gradients, rounded segments), driven by an async `Future.delayed` tick loop and `setState`-based ephemeral state with gesture-swipe input buffering; adaptive layout via `MediaQuery`.*

2. **"Can you ship cloud-backed products?"** — *Integrated Firebase Authentication (anonymous + email/password) and Cloud Firestore real-time streams (`StreamBuilder` + `ListView.builder`, server timestamps, security rules enforcing auth/ownership) to power a global top-10 leaderboard syncing scores across devices in under a second.*

3. **"Can you integrate AI safely?"** — *Connected a hosted LLM (Groq/Llama 3.1, OpenAI-compatible REST) via a 10-line async `http` POST with JSON parsing, `dart-define` secret management and try/catch graceful degradation to generate personalized post-game AI trivia — applying OOP architecture, a `ScoreCalculationMixin` for difficulty-scaled scoring, and defensive exception handling across auth, database and network boundaries.*

---

# PART 7 · v2.0 + v3 Enhancement Packs (shipped in this repo)

Production-grade upgrades across **code, UI/UX and features** — all backward-compatible with STEPS 1–8 (the starter TODO map still works verbatim; new capability is pre-written plumbing or BONUS steps).

## Code Architecture

- **`GamePhase` state machine** (`ready → playing ⇄ paused → gameOver`) replaces the lone `isGameOver` bool. The tick loop is now **pause-aware** (`if (!isPlaying) continue;`) — pausing never cancels async work; the simulation just skips ticks. Teaches: loops that *idle* beat loops that *die*.
- **Pure difficulty curve** `tickMsForApples(eaten)` — every 4 apples shortens the tick by 15 ms, floor 90 ms. Zero state, 100% unit-tested (`test/` now has 12 specs incl. lifecycle transitions: *pause-before-begin must be a no-op*).

## UI/UX

- **Tap/Swipe-to-start overlay** — the board loads in `ready` behind a `Stack` overlay; the player's *first swipe* both launches and steers (no unfair instant deaths). `Stack` is now a first-class syllabus star, not an afterthought.
- **Pause overlay + AppBar pause button + auto-pause** via `WidgetsBindingObserver` — a phone call mid-run pauses the arcade; the snake never dies because life happened.
- **Haptics** (`HapticFeedback`, pure Flutter, zero packages): light chomp on every bite, medium thud on death.
- **Score-pop** (`AnimatedSwitcher` + `ValueKey`), **crash-site red board border** on death, and **dialog v2** with run stats (`🍎 apples · 🌟 goldens · ⚡ top speed`) and a 🎉 NEW SESSION BEST callout.
- **Leaderboard**: your own row is highlighted via `uid` match — instant "where am I?"

## Features

- **Progressive speed-up** — the HUD shows a live `×1.0 → ×2.0` speed chip; the mixin's `speedBonus` is now earned *dynamically mid-run* (the harder the game gets, the more each apple pays).
- **Golden apples 🌟** — every 5th spawn: 3× score, amber palette, always pulsing, white glint sparkles. Students skin it themselves in **STEP 9 (BONUS)**.
- **🌟 Golden TTL (v3)** — a golden is a *limited-time offer*: 30 ticks (`goldenTtlTicks`, ≈5.4 s at start speed, shrinking as the game accelerates). Ignored goldens despawn into a NORMAL apple — no points, no penalty, `_spawnApple(golden: false)` breaks infinite-free-golden chains. UX telegraphing: the fruit breathes 2× faster, **blinks off** in its last 10 ticks, and a **⭐ countdown chip in the HUD** ticks down live. Architecture: pre-written `_tickGoldenTimer()` inside a `_step()` orchestrator — the student blank (`_advance`) stays purely about movement.
- **🔊 8-bit SFX (v3)** — four chiptunes (*begin / chomp / golden arpeggio / death slide*) **procedurally generated** from square/saw waves by `tools/make_sfx.py` (no audio software, no licenses, 53 KB total). Served by `SfxService` (`audioplayers`, low-latency, fire-and-forget, try/catch silence-is-safe) with an AppBar **mute toggle**. Two production lessons built in: web autoplay policy — the tap-to-start gesture is exactly what unlocks audio; and sound must never block the tick loop.

## Teaching notes (what changed in the blanks)

| STEP | Delta |
|---|---|
| 4 | Loop hint adds the pause guard: `if (!isPlaying) continue;` |
| 5 | The blank moved from `_step()` to the **movement core `_advance()`** — a pre-written `_step()` orchestrator runs timers (golden TTL) first, keeping the student code purely about movement + collision + mixin scoring (×3 if `eaten.isGolden`); respawn lives in pre-written `_afterAppleEaten()` |
| 9 *(new, bonus)* | `ApplePainter(golden:)` amber palette + glints in `lib/painting/apple_painter.dart` |
| 10 *(stretch, ungraded)* | **DJ Snake:** pitch-shift the chomp with difficulty — `_player.setPlaybackRate(_game.speedRatio)` in `_afterAppleEaten`/HUD tick |
| 11 *(stretch, ungraded)* | Personal-best persistence with `shared_preferences` |

**Updated Definition of Done:** everything in Part 4, plus — tap to start, pause to answer a call without dying, feel the speed ramp past 4 apples, chase at least one golden, and see your own row glow on the class leaderboard.

---

*Workshop artifacts: `WORKSHOP.md` (this file) · `lib/` + `STARTER_GUIDE.md` (students) · `solution/` (answer key) · `firestore.rules` · `pubspec.yaml`. Good luck, trainers — may every student die gloriously at score 250+ and get roasted by the cloud.* 🐍☁️
