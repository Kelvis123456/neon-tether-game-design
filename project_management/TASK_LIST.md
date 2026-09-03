# TASK LIST: Neon Tether

This list tracks the concrete tasks to complete the project, categorized by status.

## Active Phase: Phase 10 (Full Development — Godot port)

### To Do (Pendiente)
- [ ] Integrate real IAP and rewarded-ad SDKs — the Godot shop UI (`godot/scripts/screens/shop_screen.gd`) handles crystal-priced purchases for real, but real-money items show a "not available yet" notice instead of charging anything, since there's no store SDK/account wired up. Same for the game-over "watch ad to continue" button, not yet rebuilt in Godot.
- [ ] **Confirm on-screen rendering on a real device or a GPU-accelerated emulator.** The Android debug APK builds, installs, and runs its full engine/game logic correctly (see ENV-001), but this dev sandbox only has a software-rendered (SwiftShader) emulator available, which hits its own limitations before a frame reaches the screen — not evidence of anything wrong in the game itself, just unverified on real hardware yet.
- [ ] iOS build — needs a Mac, unavailable in this dev environment (Android is done, see Done below).
- [ ] A pass on real device input latency/feel once rendering is confirmed on real hardware.

### In Progress (En Progreso)
- [ ] Godot 4 project skeleton (`godot/`) — autoloads (`GameState`, `SaveSystem`, `AudioSynth`), AES-256 encrypted save via Godot's built-in `FileAccess.open_encrypted_with_pass`, and a full Menu ↔ Shop/Achievements/Settings/Events/Tutorial ↔ Gameplay ↔ GameOver state machine (`main.gd` + `scripts/screens/*.gd`). Confirmed working via both headless script checks and an in-engine screenshot test (real rendering) — see `BUGS.md` BUG-005/006 for two real layout bugs that check caught. Still needs: real IAP/ads, on-device rendering confirmation (see To Do).

### Done (Completado)
- [x] **Android debug build produced and verified.** Downloaded/configured the Android SDK export path (already installed on this machine at `%LOCALAPPDATA%\Android\Sdk`), pointed Godot's Java SDK setting at Android Studio's bundled JBR (`.../Android Studio/jbr`, OpenJDK 21 — the system's standalone Java 8 JRE lacks `jarsigner`), enabled `textures/vram_compression/import_etc2_astc` (mandatory for Android export), and built `godot/build/neon-tether-debug.apk` (arm64-v8a + x86_64) signed with the standard Android debug keystore. Verified with `apksigner verify` (passes, v2/v3 signed) and by actually installing it on an emulator (`adb install` → `Success`) and launching it — logcat confirms the Godot engine fully initializes and reaches `OnGodotMainLoopStarted` with zero crashes or script errors. See ENV-001 for why the emulator screen itself stayed black (a sandbox rendering limitation, not an app bug) and `README.md` for the reproducible setup steps.
- [x] Tutorial screen (`godot/scripts/screens/tutorial_screen.gd`), ported from `prototype/`'s `#screen-tutorial` + `startTutorial()`/`tutorialLoop()`: 3-step hold-to-split/release-to-merge guided flow, reachable from a new "TUTORIAL PROTOCOL" button on the menu. Completing it unlocks the "First Transmission" achievement via `GameState.complete_tutorial()` — previously unreachable in the Godot port since nothing else ever completed it.
- [x] Godot production port of every screen from `prototype/`: Menu (crystals/best score/nav/tutorial), Grid Shop (tethers/cores/upgrades tabs, real crystal purchases), System Achievements (real progress tracking), Configuration (music/haptics/colorblind), Live Matrix Events (leaderboard + daily missions), Tutorial. Ported content 1:1 from `prototype/index.html`'s catalog/achievement copy.
- [x] Daily missions system (`GameState._ensure_daily_missions()`) — 3 objectives per day picked from a template pool and seeded by date, matching `docs/GDD.md` 2.2 ("Complete 3 dynamic objectives daily"); rewards crystals on completion.
- [x] Object pooling for obstacles/crystals — turned out to be moot: `gameplay.gd` never allocates a Node per obstacle/crystal (they're plain Dictionary entries drawn via one `_draw()` call), so there's no per-spawn Node churn to pool in the first place. Noted here instead of silently skipped.
- [x] Split/merge spring-easing mechanic and collision rules ported from `prototype/app.js` to `godot/scripts/gameplay.gd` — logic and constants carried over 1:1, plus BUG-004 fixed along the way (see `BUGS.md`). Skin colors (tether choice + colorblind mode) and the `double-crystals` collect-radius upgrade are now applied in gameplay too, not just cosmetic in the shop.
- [x] Verified live in the real Godot 4.7.2 editor (downloaded and run in this environment) — headless script-error checks, an in-engine automated screenshot pass across all screens including the full tutorial flow, and an actual played gameplay run (menu → gameplay → crash → persisted save) via simulated input. Two real layout bugs found and fixed this way (BUG-005, BUG-006) that a headless-only check could never have caught.

### Done (Completado) — earlier phases
- [x] Market research, ideation, concept validation (Phases 1-3).
- [x] Game Design Document (Phase 4).
- [x] Browser UX/UI prototype covering every screen (Phase 5).
- [x] Art direction guide with 3 palettes, VFX and audio specs (Phase 6).
- [x] Engine selection: Godot 4 (Phase 7).
- [x] Technical architecture document (Phase 8).
- [x] Vertical slice validated in-browser: spring easing tuning, audio envelopes, "Grazed" combo feel (Phase 9).
- [x] Prototype polish pass: real background music synthesis, localStorage persistence (crystals, owned skins, best score, settings), local leaderboard driven by real run history, colorblind mode applied consistently across glows/backgrounds (not just spheres).
