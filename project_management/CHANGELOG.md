# CHANGELOG: Neon Tether

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added (Phase 10 — VFX + app icon)
- Implemented the three VFX specs from `docs/art_direction.md` section 2, which had only ever existed as design-doc prose until now: Tether Ribbon Trails (tapering, fading 0.8→0.0 over a 200ms window), The Snap Flash (expanding/fading white shockwave ring on merge, 150ms), and Shatter Spark Burst (24 particles scattering outward with gravity on crash) — all in `godot/scripts/gameplay.gd`, drawn the same lightweight way as everything else there (no particle-node overhead).
- Real app icon (`godot/icon.png`, 512x512), generated in-engine from the game's own visual motif rather than left as the default Godot robot.

### Fixed (Phase 10 — Android rendering, round 2)
- BUG-007: simplifying `project.godot`'s renderer setting down to one key silently regressed Android back to the `mobile`/Vulkan renderer that ENV-001 documents as broken on this emulator — the Android runtime specifically needs the `.mobile`-suffixed override, not just the base key. Restored both. See `BUGS.md`.

### Fixed (Phase 10 — Android rendering confirmed)
- ENV-001 resolved for real: relaunched the emulator with actual host GPU acceleration (`-gpu host`, this machine's Intel UHD 620 via Vulkan 1.3) instead of forced software rendering. `gl_compatibility` then rendered correctly end-to-end — menu, shop nav, and two full played gameplay runs (via simulated `adb input` touch), with best score correctly persisting across them (40m → 41m) and the game-over screen showing no layout issues. `mobile` (Vulkan) still failed to present even with real hardware behind it, pointing at the Android Emulator's own Vulkan swapchain specifically rather than a hardware limitation — so the project's renderer is now committed as `gl_compatibility` (`project.godot`).

### Added (Phase 10 — Android debug build)
- Real, signed Android debug build (`godot/build/neon-tether-debug.apk`, arm64-v8a + x86_64) — configured Godot's Android/Java SDK paths against tooling already present on this machine, enabled the mandatory ETC2/ASTC texture-compression setting, and set up an Android export preset using the standard debug keystore. Verified with `apksigner verify` and by installing/launching it on an emulator: the Godot engine reaches its main loop with zero crashes (confirmed via `adb logcat`).
- Documented the reproducible local setup steps in `README.md` (`export_presets.cfg` itself stays gitignored — it embeds a machine-specific keystore path).

### Fixed / Investigated
- ENV-001 (not a code bug): isolated why the on-screen frame stayed black on this dev sandbox's only available emulator to two independent software-rendering limits — a Vulkan present-queue failure on the `mobile` renderer, and a shader-compile uniform-budget failure on `gl_compatibility`, both specific to the emulator's software GPU (SwiftShader), neither touching any Neon Tether code. See `project_management/BUGS.md`.

### Added (Phase 10 — Godot UI + missions + tutorial)
- Full Godot production UI for Menu, Grid Shop (tethers/cores/upgrades, real crystal purchases), System Achievements (real progress tracking), Configuration (music/haptics/colorblind), Live Matrix Events (leaderboard + daily missions), and Tutorial — `godot/scripts/screens/*.gd`, ported 1:1 from `prototype/index.html`'s catalog/achievement/event/tutorial content.
- Daily missions system (`GameState._ensure_daily_missions()`), matching `docs/GDD.md`'s "3 dynamic objectives daily" — the browser prototype never actually built this despite documenting it as done.
- Tutorial screen (3-step hold-to-split/release-to-merge guided flow), reachable from a new "TUTORIAL PROTOCOL" menu button. Completing it unlocks "First Transmission" via `GameState.complete_tutorial()` — previously unreachable in the Godot port.
- Tether skin colors (per-cosmetic + colorblind override, ported from `applySkinStyles()`) and the `double-crystals` upgrade's +20% crystal collect radius now actually apply in gameplay, not just cosmetically in the shop.
- Downloaded and ran Godot 4.7.2 for real in this dev environment: headless script-error checks plus an in-engine automated screenshot test across every screen (menu, shop, achievements, settings, events, gameplay, and the full tutorial flow), and an actual played run via simulated input.

### Fixed
- BUG-005: sub-screens (Shop/Achievements/Settings/Events) rendered with the Main Menu bleeding through underneath — their root `Control` had no explicit size, so every full-rect child inside collapsed to 0x0. Only visible with real rendering, not the headless check.
- BUG-006: `UIHelpers.label()`'s default-on autowrap could squeeze a short badge label (e.g. the achievement reward tag) to a sliver next to a wider sibling, wrapping it into an unreadable stack of single characters. Autowrap is now opt-in.

### Added (Phase 10 — Godot port started)
- Godot 4 project skeleton under `godot/`: `project.godot` (portrait 450x800 design viewport, `canvas_items`/`keep` stretch), and autoload singletons `SaveSystem`, `GameState`, `AudioSynth`.
- Core split/merge spring-easing mechanic, procedural obstacle/crystal spawning, and collision/graze rules ported from `prototype/app.js` to `godot/scripts/gameplay.gd`, constants carried over unscaled from the prototype's CSS/JS.
- Procedural SFX/BGM in `godot/autoload/AudioSynth.gd` (split/merge/graze/crash tones + ambient arpeggio loop) via `AudioStreamGenerator`, replacing the prototype's Web Audio API code.
- AES-256 encrypted save file (`godot/autoload/SaveSystem.gd`, via Godot's `FileAccess.open_encrypted_with_pass`), replacing the prototype's plain `localStorage`.
- Minimal Menu → Gameplay → GameOver state machine (`godot/scripts/main.gd`) so the ported mechanic is actually playable end-to-end, pending the real menu/shop/settings UI.

### Fixed
- BUG-004: a graze inside the collision band could fire `triggerGraze()`/bump the combo multiple times per obstacle in `prototype/app.js`; fixed in the Godot port by resolving each obstacle once. See `BUGS.md`.

### Added
- Design documentation for Phases 1-9: market research, ideation, concept validation, GDD, art direction, technology selection (Godot 4), architecture, and vertical slice report.
- Full browser prototype (`prototype/`) covering every screen: splash, menu, tutorial, gameplay, pause, game over, shop, achievements, settings, events.
- Real background music synthesis (ambient arpeggio loop via Web Audio API), gated by the music setting.
- `localStorage`-backed persistence for crystals, best score, owned/selected skins, run history, and settings.
- Local leaderboard driven by real run history instead of static hardcoded rows.
- Consistent colorblind mode: glows and obstacle backgrounds now recolor along with spheres/tether (previously only partial).

### Changed
- Project management docs (`ROADMAP.md`, `TASK_LIST.md`) corrected to reflect actual progress (Phases 1-9 complete) — they previously still marked Phase 1 as "In Progress" despite the design work being far ahead.
- Removed leftover references to the project's old working name ("Antigravity Game Project" / "AntigravityGame") across `project_management/`.

## [0.1.0] - 2026-07-12
### Added
- Initial commit: project folder structure and management docs (`ROADMAP.md`, `TASK_LIST.md`, `DECISIONS.md`, `CHANGELOG.md`, `RISKS.md`, `IMPROVEMENTS.md`, `BUGS.md`, `OPTIMIZATIONS.md`).
