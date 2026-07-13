# OPTIMIZATIONS LOG: Neon Tether

*Note: these targets apply to the Phase 10 Godot production build. The current browser prototype is a UX/feel-validation tool, not optimized against these numbers.*

This document tracks performance targets, profiling sessions, and code/art optimizations.

---

## Targets
- **Target Frame Rate:** Stable 60 FPS on mid-range Android & iOS devices (e.g., iPhone 11, Snapdragon 680).
- **Target Battery Consumption:** Under 5% charge usage per hour of continuous gameplay.
- **Target App Size:** Under 100 MB initial download.

---

## Planned Optimizations
- **Texture Atlases:** Combine all UI and sprite graphics to minimize draw calls.
- **Object Pooling:** Pool obstacles, particles, and effects to avoid garbage collection spikes.
- **Audio Compression:** Compress music to lightweight Ogg/MP3 formats and sound effects to WAV/ADPCM.
