# CHANGELOG: Neon Tether

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

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
