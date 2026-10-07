#!/usr/bin/env python3
"""SnakeX Cloud · chiptune SFX generator.

Zero audio software, zero licenses: the four retro WAVs in assets/sfx/ are
synthesized right here from raw square/saw waves (classic 8-bit chips did
exactly this). Regenerate any time:  python3 tools/make_sfx.py
"""
import math
import os
import struct
import wave

SR = 22050  # sample rate (Hz) — lo-fi on purpose
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")


def square(freq: float, t: float) -> float:
    return 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0


def saw(freq: float, t: float) -> float:
    return 2.0 * ((freq * t) % 1.0) - 1.0


def note(freq: float, dur: float, wave_fn=square, volume: float = 0.5):
    """One constant-pitch note with a linear decay envelope."""
    n = int(SR * dur)
    return [wave_fn(freq, i / SR) * (1.0 - i / n) * volume for i in range(n)]


def sweep(f0: float, f1: float, dur: float, wave_fn=square, volume: float = 0.5):
    """Pitch glides f0→f1 while decaying (bells, slides, deaths)."""
    n = int(SR * dur)
    return [
        wave_fn(f0 + (f1 - f0) * (i / n), i / SR) * (1.0 - (i / n) ** 2) * volume
        for i in range(n)
    ]


def write(name: str, samples):
    os.makedirs(OUT, exist_ok=True)
    frames = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples
    )
    path = os.path.join(OUT, name)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(frames)
    print(f"  {name}: {len(samples)} samples, {os.path.getsize(path)} bytes")


def main():
    print("Synthesizing SnakeX Cloud chiptunes → assets/sfx/")
    # 🍎 chomp — quick upward square blip
    write("chomp.wav", sweep(500, 900, 0.08, square, 0.45))
    # ▶ begin — confident two-note "get ready"
    write("begin.wav", note(440, 0.09) + note(660, 0.14))
    # 🌟 golden — sparkling 4-note major arpeggio (C5 E5 G5 C6)
    write(
        "golden.wav",
        note(523, 0.06) + note(659, 0.06) + note(784, 0.06) + note(1047, 0.16),
    )
    # 💀 death — long descending saw slide
    write("death.wav", sweep(420, 55, 0.55, saw, 0.5))
    print("Done. Restart the app (assets are bundled at build time).")


if __name__ == "__main__":
    main()
