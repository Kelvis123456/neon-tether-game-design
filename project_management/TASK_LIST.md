# TASK LIST: Neon Tether

This list tracks the concrete tasks to complete the project, categorized by status.

## Active Phase: Phase 10 (Full Development — Godot port)

### To Do (Pendiente)
- [ ] Integrate real IAP and rewarded-ad SDKs — the Godot shop UI (`godot/scripts/screens/shop_screen.gd`) handles crystal-priced purchases for real, but real-money items show a "not available yet" notice instead of charging anything, since there's no store SDK/account wired up. Same for the game-over "watch ad to continue" button, not yet rebuilt in Godot.
- [ ] Tutorial screen (from `prototype/`'s `#screen-tutorial`) — not ported yet, which is also why the "First Transmission" achievement can never unlock.
- [ ] Produce Android & iOS builds for Phase 11 QA — needs the Android SDK/signing keystore (and a Mac for iOS), none of which are available in this dev environment.
- [ ] A pass on real device input latency/feel once an actual build exists (desktop mouse input was what got tested here).

### In Progress (En Progreso)
- [ ] Godot 4 project skeleton (`godot/`) — autoloads (`GameState`, `SaveSystem`, `AudioSynth`), AES-256 encrypted save via Godot's built-in `FileAccess.open_encrypted_with_pass`, and a full Menu ↔ Shop/Achievements/Settings/Events ↔ Gameplay ↔ GameOver state machine (`main.gd` + `scripts/screens/*.gd`). Confirmed working via both headless script checks and an in-engine screenshot test (real rendering) — see `BUGS.md` BUG-005/006 for two real layout bugs that check caught. Still needs: tutorial screen, real IAP/ads (see To Do).

### Done (Completado)
- [x] Godot production port of every non-tutorial screen from `prototype/`: Menu (crystals/best score/nav), Grid Shop (tethers/cores/upgrades tabs, real crystal purchases), System Achievements (real progress tracking), Configuration (music/haptics/colorblind), Live Matrix Events (leaderboard + daily missions). Ported content 1:1 from `prototype/index.html`'s catalog/achievement copy.
- [x] Daily missions system (`GameState._ensure_daily_missions()`) — 3 objectives per day picked from a template pool and seeded by date, matching `docs/GDD.md` 2.2 ("Complete 3 dynamic objectives daily"); rewards crystals on completion.
- [x] Object pooling for obstacles/crystals — turned out to be moot: `gameplay.gd` never allocates a Node per obstacle/crystal (they're plain Dictionary entries drawn via one `_draw()` call), so there's no per-spawn Node churn to pool in the first place. Noted here instead of silently skipped.
- [x] Split/merge spring-easing mechanic and collision rules ported from `prototype/app.js` to `godot/scripts/gameplay.gd` — logic and constants carried over 1:1, plus BUG-004 fixed along the way (see `BUGS.md`). Skin colors (tether choice + colorblind mode) and the `double-crystals` collect-radius upgrade are now applied in gameplay too, not just cosmetic in the shop.
- [x] Verified live in the real Godot 4.7.2 editor (downloaded and run in this environment) — headless script-error checks, an in-engine automated screenshot pass across all 6 screens, and an actual played run (menu → gameplay → crash → persisted save) via simulated input. Two real layout bugs found and fixed this way (BUG-005, BUG-006) that a headless-only check could never have caught.

### Done (Completado) — earlier phases
- [x] Market research, ideation, concept validation (Phases 1-3).
- [x] Game Design Document (Phase 4).
- [x] Browser UX/UI prototype covering every screen (Phase 5).
- [x] Art direction guide with 3 palettes, VFX and audio specs (Phase 6).
- [x] Engine selection: Godot 4 (Phase 7).
- [x] Technical architecture document (Phase 8).
- [x] Vertical slice validated in-browser: spring easing tuning, audio envelopes, "Grazed" combo feel (Phase 9).
- [x] Prototype polish pass: real background music synthesis, localStorage persistence (crystals, owned skins, best score, settings), local leaderboard driven by real run history, colorblind mode applied consistently across glows/backgrounds (not just spheres).
