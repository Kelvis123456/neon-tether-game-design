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
| **BUG-005** | `main.gd`'s `_show_sub_screen()` (Shop/Achievements/Settings/Events) instantiated each screen's root `Control` with no explicit size. A fresh `Control` defaults to a 0x0 rect; its own anchors resolve against the viewport (its parent is a `CanvasLayer`, not a `Control`), but its *children*'s anchors resolve against that 0x0 rect — so every full-rect/full-width child inside the screen (background `ColorRect`, header bar) collapsed to 0x0 too, and the Main Menu screen showed straight through underneath. Only visible with real rendering — the headless script-error check couldn't catch it. | High (visual) | Fixed: `screen.set_anchors_preset(Control.PRESET_FULL_RECT)` right after instantiating each screen in `main.gd`. |
| **BUG-006** | `UIHelpers.label()` enabled `autowrap_mode` on every label by default. A wrapping `Label` reports a much smaller *minimum* size to its parent container than its natural single-line width — so a short "badge" label with no explicit `custom_minimum_size` (e.g. the achievement reward tag "💎 200") could get squeezed to a sliver by a wider sibling in the same row and wrap into an unreadable vertical stack of single characters. | Medium (visual) | Fixed: autowrap is now opt-in (`wrap: true` param, default `false`); call sites with genuine paragraph text (achievement/upgrade descriptions, the settings "about" text, mission labels) opt in explicitly and set their own width. |

*Note: BUG-001 through BUG-003 were prototype (browser) bugs, already fixed there. BUG-004 through BUG-006 were found and fixed in the Godot port (`feature/phase-10-godot-skeleton`) — BUG-005 and BUG-006 specifically were only caught by an in-engine screenshot test (real rendering), not the headless parse/runtime check, which is worth remembering next time something "loads with zero errors" gets called done.*
