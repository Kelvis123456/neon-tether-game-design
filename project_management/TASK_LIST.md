# TASK LIST: Neon Tether

This list tracks the concrete tasks to complete the project, categorized by status.

## Active Phase: Phase 10 (Full Development — Godot port)

### To Do (Pendiente)
- [ ] Set up Godot 4 project skeleton per `docs/architecture.md` (GameLoop, GamePlayCore, AudioSynthesizer, Renderer2D, HapticController, SaveSystem).
- [ ] Port split/merge spring-easing mechanic and collision rules from `prototype/app.js` to GDScript.
- [ ] Implement daily missions system (currently only a design idea, not built anywhere).
- [ ] Integrate real IAP and rewarded-ad SDKs (prototype only simulates these with `alert()`).
- [ ] Implement AES-256 encrypted save system per `docs/architecture.md` (prototype uses plain localStorage).
- [ ] Produce Android & iOS builds for Phase 11 QA.

### In Progress (En Progreso)
*Nothing currently in progress — Phase 10 has not started.*

### Done (Completado)
- [x] Market research, ideation, concept validation (Phases 1-3).
- [x] Game Design Document (Phase 4).
- [x] Browser UX/UI prototype covering every screen (Phase 5).
- [x] Art direction guide with 3 palettes, VFX and audio specs (Phase 6).
- [x] Engine selection: Godot 4 (Phase 7).
- [x] Technical architecture document (Phase 8).
- [x] Vertical slice validated in-browser: spring easing tuning, audio envelopes, "Grazed" combo feel (Phase 9).
- [x] Prototype polish pass: real background music synthesis, localStorage persistence (crystals, owned skins, best score, settings), local leaderboard driven by real run history, colorblind mode applied consistently across glows/backgrounds (not just spheres).
