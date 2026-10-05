import 'package:audioplayers/audioplayers.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · SfxService [PRE-WRITTEN — walkthrough only]
/// Zero-asset-magic: the four chiptune WAVs in assets/sfx/ were generated
/// procedurally from square/saw waves (see tools/make_sfx.py) — no audio
/// editing software, no licenses, pure 8-bit.
///
/// PRODUCTION TEACHING NOTES:
///  • Web autoplay policy: audio may only start AFTER a user gesture. Our
///    tap-to-start overlay IS that gesture → begin() legally unlocks SFX.
///  • play() is fire-and-forget: audio must NEVER block the tick loop.
///  • try/catch: sound is juice, not logic — a missing audio device must
///    never crash a run (same exception-handling rule as the AI service).
/// ─────────────────────────────────────────────────────────────────────────
class SfxService {
  SfxService() {
    _player.setPlayerMode(PlayerMode.lowLatency); // short fx, instant restart
  }

  final AudioPlayer _player = AudioPlayer();
  bool muted = false;

  Future<void> _play(String file, {double volume = 0.5}) async {
    if (muted) return;
    try {
      await _player.stop(); // cut the tail → rapid chomps stay crisp
      await _player.play(AssetSource('sfx/$file'), volume: volume);
    } catch (_) {
      // audio unavailable (emulator profile, web policy) → stay silent, play on
    }
  }

  Future<void> begin() => _play('begin.wav'); // ▶ run start
  Future<void> chomp() => _play('chomp.wav', volume: 0.35); // 🍎 bite
  Future<void> golden() => _play('golden.wav'); // 🌟 3× prize arpeggio
  Future<void> death() => _play('death.wav', volume: 0.6); // 💀 slide-down

  /// STRETCH (#10): pitch-shift with the speed curve — call
  /// `_player.setPlaybackRate(_game.speedRatio)` after every apple.
  Future<void> dispose() => _player.dispose();
}
