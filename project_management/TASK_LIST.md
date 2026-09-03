# TASK LIST: Neon Tether

This list tracks the concrete tasks to complete the project, categorized by status.

## Active Phase: Phase 10 (Full Development — Godot port)

### To Do (Pendiente)
- [ ] Integrate real IAP and rewarded-ad SDKs — the Godot shop UI (`godot/scripts/screens/shop_screen.gd`) handles crystal-priced purchases for real, but real-money items show a "not available yet" notice instead of charging anything, since there's no store SDK/account wired up. Same for the game-over "watch ad to continue" button, not yet rebuilt in Godot.
- [ ] Re-confirm rendering on a real physical device before shipping — verified on a hardware-GPU-accelerated *emulator* (see Done below), which is strong evidence but not a substitute for real device/driver variety, especially since `mobile` (Vulkan) had emulator-specific presentation issues that `gl_compatibility` didn't.
- [ ] iOS build — needs a Mac, unavailable in this dev environment (Android is done, see Done below).
- [ ] A pass on real device input latency/feel (touchscreen, not the emulator's simulated `adb input` events used so far).

### In Progress (En Progreso)
- [ ] Godot 4 project skeleton (`godot/`) — autoloads (`GameState`, `SaveSystem`, `AudioSynth`), AES-256 encrypted save via Godot's built-in `FileAccess.open_encrypted_with_pass`, and a full Menu ↔ Shop/Achievements/Settings/Events/Tutorial ↔ Gameplay ↔ GameOver state machine (`main.gd` + `scripts/screens/*.gd`). Confirmed working via headless script checks, an in-engine screenshot test, and a real Android build actually played on an emulator (see Done below). Still needs: real IAP/ads, real-device confirmation (see To Do).

### Done (Completado)
- [x] **VFX pass from `docs/art_direction.md` section 2** — the three specified effects, previously only described in the doc, now actually implemented in `godot/scripts/gameplay.gd`: Tether Ribbon Trails (tapering, fading 0.8→0.0 over 200ms), The Snap Flash (expanding white shockwave ring on merge, 150ms), and Shatter Spark Burst (24 particles scattering outward with gravity on crash). Verified via an in-engine screenshot test showing all three mid-animation, and confirmed rendering correctly on the Android build too.
- [x] Custom app icon (`godot/icon.png`) generated procedurally in-engine (a `SubViewport` drawing the game's own cyan/magenta tether-and-spheres motif, captured and saved as a 512x512 PNG) — replaces the default Godot robot icon. Set as `config/icon` in `project.godot`.
- [x] **Android debug build produced, installed, and actually played — confirmed rendering correctly.** Downloaded/configured the Android SDK export path (already installed on this machine at `%LOCALAPPDATA%\Android\Sdk`), pointed Godot's Java SDK setting at Android Studio's bundled JBR (`.../Android Studio/jbr`, OpenJDK 21 — the system's standalone Java 8 JRE lacks `jarsigner`), enabled `textures/vram_compression/import_etc2_astc` (mandatory for Android export), and built `godot/build/neon-tether-debug.apk` (arm64-v8a + x86_64) signed with the standard Android debug keystore. First pass hit a software-rendering-only emulator limitation (ENV-001 in `BUGS.md`) — relaunching the emulator with real host GPU acceleration (`-gpu host`, using this machine's Intel UHD 620) and switching the project to the `gl_compatibility` renderer resolved it completely: the menu, shop nav, and a full played run (`adb input` simulating touch) all render correctly, including the game-over screen with the correct score, and best score persisting across two separate runs (40m → 41m). `renderer/rendering_method` is now committed as `gl_compatibility`. See `README.md` for the reproducible setup steps.
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
