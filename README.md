# 🐍☁️ SnakeX Cloud

**A 2-hour, industry-grade Flutter workshop for 3rd-year engineering students.**
A retro 20×20 arcade snake game with custom canvas graphics, a real-time
Cloud Firestore global leaderboard, and an AI "intermission host" (Groq/Gemini
over plain REST) that roasts your score after every run.

**v2/v3 gameplay:** tap-to-start overlay · pause + auto-pause on app switch ·
haptics · **8-bit SFX** (procedurally generated chiptunes via
`tools/make_sfx.py`) with mute toggle · progressive speed-up (×1.0→×2.0) ·
golden apples worth 3× every 5th spawn — **with a 30-tick TTL**, live HUD
countdown and blink-when-expiring · session-best tracking · your row
highlighted on the live leaderboard.

Built to cover **100% of the university syllabus**: Dart OOP · mixins ·
exceptions · async/streams · Flutter layouts · GridView/ListView ·
AnimatedContainer · CustomPainter · setState & app state · explicit routes ·
Firebase Auth · Firestore live CRUD · REST API integration.

## 📚 Start here

| Doc | For whom | Contents |
|---|---|---|
| **[WORKSHOP.md](WORKSHOP.md)** | Trainer / mentor | Full curriculum: CoT design reasoning, syllabus→feature map, analogies, the 120-min agenda with minute marks, rubric |
| **[STARTER_GUIDE.md](STARTER_GUIDE.md)** | Students | Setup guide + the TODO map (STEPS 1–8) |

## 🗂️ Repo map

```
├── WORKSHOP.md              ← the master curriculum (read this first)
├── STARTER_GUIDE.md         ← student setup guide + TODO map
├── pubspec.yaml             ← deps: firebase_*, cloud_firestore, http
├── firestore.rules          ← workshop-safe leaderboard rules
├── lib/                     ← STUDENT STARTER KIT (shell + TODOs 1–8)
├── test/workshop_logic_test.dart ← red→green spec for STEPS 1–5
└── solution/lib/            ← trainer reference / answer key
    ├── models/game_models.dart        (OOP: Point, Snake, Direction, Apple)
    ├── mixins/score_calculation_mixin.dart
    ├── game/snake_game_controller.dart (Future.delayed tick loop, collision)
    ├── painting/apple_painter.dart + snake_segment_painter.dart
    ├── services/ai_trivia_service.dart (10-line AI REST POST)
    ├── services/leaderboard_service.dart (Firestore CRUD + stream)
    ├── widgets/leaderboard_panel.dart  (StreamBuilder + ListView.builder)
    └── screens/ + main.dart            (routes, auth gate, HUD, board)
```

## ⚡ Trainer quickstart

```bash
flutter pub get
flutter create .                               # platform folders
flutterfire configure                          # needs a Firebase project
firebase deploy --only firestore:rules         # publish leaderboard rules
flutter run --dart-define=GROQ_API_KEY=gsk_... # any Groq free-tier key
```

No AI key in class? The app detects an empty key and serves canned retro
roasts — the workshop never blocks on third-party Wi-Fi (that's a syllabus
lesson in itself).
