# DECISIONS LOG: Neon Tether

This document records the design and technical decisions made during the project, detailing the context, options considered, and rationales.

---

## [DEC-001] Project Path Selection

* **Date:** 2026-07-01
* **Status:** Approved
* **Context:** The workspace root is `C:/Windows/System32`, which is a protected system directory. We need a safe user-space directory for development.
* **Options Considered:**
  1. `C:/Windows/System32` (Too risky, permissions issues, potential OS instability).
  2. `C:/Users/Usuario/Documents/NeonTether` (Safe, standard documents folder, clean git-ready location).
  3. `C:/Users/Usuario/Desktop/NeonTether` (Visible, but clutters user's desktop).
* **Decision:** Option 2 (`C:/Users/Usuario/Documents/NeonTether`).
* **Rationale:** It separates our work from system files, avoids visual clutter on the desktop, and is fully accessible.
* **Consequences:** We requested and received write permissions for this folder.

---

## [DEC-002] Production Engine Selection

* **Date:** 2026-07-12
* **Status:** Approved
* **Context:** Phase 7 evaluated six engine/stack options against the game's core requirements: stable 60 FPS on low-end mobile, extremely low input latency (critical for the graze-timing mechanic), rich 2D shader support for neon glows, and a lightweight build size.
* **Options Considered:** Unity, Unreal Engine, Godot 4, Defold, Flutter + Flame, Phaser + Capacitor. Full comparison in `docs/technology_selection.md`.
* **Decision:** Godot 4.
* **Rationale:** Native touch input handling with sub-millisecond latency, native 2D canvas/shader support ideal for neon trail rendering without heavy textures, ~12MB build size, MIT license (no royalties).
* **Consequences:** Phase 10 (full development) will be a Godot/GDScript port of the mechanic already validated in the browser prototype — not a continuation of the HTML/CSS/JS codebase.

---

## [DEC-003] "Finished" Scope for This Design Phase

* **Date:** 2026-07-13
* **Status:** Approved
* **Context:** The project owner asked to "finish" Neon Tether and publish it to GitHub and the portfolio. The sibling design projects in the same portfolio (PHASE, SKIM) never reached a real production/QA build either — both explicitly mark Phase 10 (full development) and Phase 11 (QA) as "Pending" in their README, treating "complete documentation + validated prototype" as the finished state for this kind of project.
* **Options Considered:**
  1. Only clean up stale `project_management/` docs, leave the prototype untouched.
  2. Match the PHASE/SKIM standard: complete/accurate docs through Phase 9, polished browser prototype, Phase 10-11 explicitly deferred.
  3. Actually port the mechanic to Godot 4 for a real mobile build (multi-session effort, out of scope for one sitting).
* **Decision:** Option 2.
* **Rationale:** Keeps Neon Tether consistent with the rest of the portfolio's "pre-production complete" convention instead of promising a mobile build that doesn't exist.
* **Consequences:** Phase 10 (Godot port) and Phase 11 (QA) remain future work, tracked in `ROADMAP.md` and `TASK_LIST.md`. The browser prototype was polished (real persistence, BGM, local leaderboard, consistent colorblind mode) but not re-platformed.
