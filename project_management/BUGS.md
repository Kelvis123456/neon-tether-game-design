# BUGS LOG: Neon Tether

This document tracks known issues, their severity, reproduction steps, and resolution status.

---

## Active Bugs

*No bugs currently reported.*

---

## Resolved Bugs

| ID | Description | Severity | Resolution |
| :--- | :--- | :--- | :--- |
| **BUG-001** | Colorblind mode (`setting-colorblind`) only recolored the spheres and tether line — glows (`--glow-cyan`/`--glow-magenta`) and obstacle backgrounds stayed the original hue, since they were static `rgba()` values instead of derived from the active neon color. | Medium (accessibility) | Fixed: glow shadows are now computed dynamically from the active color via `setNeonColors()`; obstacle backgrounds use `color-mix()` against the CSS variables. |
| **BUG-002** | No progress persistence — crystals, owned skins, best score, and settings reset to defaults on every page reload. | Medium | Fixed: added `localStorage`-backed `saveProgress()`/`loadProgress()`. |
| **BUG-003** | The "Global Leaderboard" on the Events screen was fully hardcoded HTML with no connection to actual gameplay — the player's row never changed after a run. | Low | Fixed: `renderLeaderboard()` now rebuilds the list from real `state.bestScore` against fixed flavor NPC scores. |
| **BUG-004** | `moveAndCollide()` in `prototype/app.js` re-checked every obstacle's collision distance every frame it stayed within the `GRAZE_BAND` (~9 frames at the run speed used), so a single safely-passed obstacle could call `triggerGraze()` — and bump the combo — multiple times instead of once. Found while porting the mechanic 1:1 to `godot/scripts/gameplay.gd`. | Low (game feel / scoring) | Fixed in the Godot port: each obstacle dictionary gets a `resolved` flag set the first time it's checked in-band, so collision/graze only evaluates once per obstacle. The browser prototype still has the original behavior (not touched, since Phase 10 supersedes it). |

*Note: BUG-001 through BUG-003 were prototype (browser) bugs, already fixed there. BUG-004 was found and fixed during the initial Godot port (`feature/phase-10-godot-skeleton`).*
