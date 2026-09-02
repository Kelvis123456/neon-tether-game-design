# TASK LIST: Neon Tether

This list tracks the concrete tasks to complete the project, categorized by status.

## Active Phase: Phase 10 (Full Development — Godot port)

### To Do (Pendiente)
- [ ] Full menu/shop/settings/achievements/events UI in Godot (currently a bare PLAY-button stub — the real screens from `prototype/` haven't been rebuilt as Godot UI yet).
- [ ] Implement daily missions system (currently only a design idea, not built anywhere).
- [ ] Integrate real IAP and rewarded-ad SDKs (prototype only simulates these with `alert()`).
- [ ] Object pooling for obstacles/crystals per `OPTIMIZATIONS.md` (current port allocates/frees per spawn, matching the prototype's DOM-node behavior, not yet the pooled architecture).
- [ ] Produce Android & iOS builds for Phase 11 QA.
- [ ] Open `godot/project.godot` in the real Godot 4 editor and play-test — the skeleton below was authored by hand (no editor available in this environment) and has not been run yet. Report any parse/runtime errors back for a fast follow-up fix.

### In Progress (En Progreso)
- [ ] Godot 4 project skeleton (`godot/`) — done: autoloads (`GameState`, `SaveSystem`, `AudioSynth`), AES-256 encrypted save via Godot's built-in `FileAccess.open_encrypted_with_pass`, and a minimal Menu → Gameplay → GameOver state machine. Still needs the real menu/shop UI (see To Do) and an in-editor test pass.
- [ ] Split/merge spring-easing mechanic and collision rules ported from `prototype/app.js` to `godot/scripts/gameplay.gd` — logic and constants carried over 1:1 (same spring-lerp factor, obstacle/crystal geometry, graze band), plus BUG-004 fixed along the way (see `BUGS.md`). Unverified in the actual editor yet (see To Do).

### Done (Completado)
- [x] Market research, ideation, concept validation (Phases 1-3).
- [x] Game Design Document (Phase 4).
- [x] Browser UX/UI prototype covering every screen (Phase 5).
- [x] Art direction guide with 3 palettes, VFX and audio specs (Phase 6).
- [x] Engine selection: Godot 4 (Phase 7).
- [x] Technical architecture document (Phase 8).
- [x] Vertical slice validated in-browser: spring easing tuning, audio envelopes, "Grazed" combo feel (Phase 9).
- [x] Prototype polish pass: real background music synthesis, localStorage persistence (crystals, owned skins, best score, settings), local leaderboard driven by real run history, colorblind mode applied consistently across glows/backgrounds (not just spheres).
