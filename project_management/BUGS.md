# BUGS LOG: Neon Tether

This document tracks known issues, their severity, reproduction steps, and resolution status.

---

## Active Bugs

*No bugs currently reported in the browser prototype (`prototype/`).*

---

## Resolved Bugs

| ID | Description | Severity | Resolution |
| :--- | :--- | :--- | :--- |
| **BUG-001** | Colorblind mode (`setting-colorblind`) only recolored the spheres and tether line — glows (`--glow-cyan`/`--glow-magenta`) and obstacle backgrounds stayed the original hue, since they were static `rgba()` values instead of derived from the active neon color. | Medium (accessibility) | Fixed: glow shadows are now computed dynamically from the active color via `setNeonColors()`; obstacle backgrounds use `color-mix()` against the CSS variables. |
| **BUG-002** | No progress persistence — crystals, owned skins, best score, and settings reset to defaults on every page reload. | Medium | Fixed: added `localStorage`-backed `saveProgress()`/`loadProgress()`. |
| **BUG-003** | The "Global Leaderboard" on the Events screen was fully hardcoded HTML with no connection to actual gameplay — the player's row never changed after a run. | Low | Fixed: `renderLeaderboard()` now rebuilds the list from real `state.bestScore` against fixed flavor NPC scores. |

*Note: none of these are Godot/production bugs — Phase 10 (the actual Godot port) hasn't started, so there's no production code to have bugs yet.*
