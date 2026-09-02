# ROADMAP: Neon Tether

This roadmap details the planned stages for Neon Tether, an original mobile rhythm-arcade physics runner. Quality is our highest priority, aiming to deliver a polished, commercial-grade product.

## Phases Overview

| Phase | Description | Status |
| :--- | :--- | :--- |
| **Phase 1** | Market Research & Opportunity Analysis | ✅ Done |
| **Phase 2** | Ideation (30+ Concepts & Selection) | ✅ Done |
| **Phase 3** | Concept Validation | ✅ Done |
| **Phase 4** | Game Design Document (GDD) | ✅ Done |
| **Phase 5** | UX/UI Prototyping (browser prototype) | ✅ Done |
| **Phase 6** | Art Direction & Visual Identity | ✅ Done |
| **Phase 7** | Engine & Technology Selection | ✅ Done — Godot 4 selected |
| **Phase 8** | Technical Architecture Design | ✅ Done |
| **Phase 9** | Vertical Slice Development | ✅ Done — validated in browser prototype |
| **Phase 10** | Full Development (Godot production build) | 🔧 In Progress |
| **Phase 11** | QA & Polishing | ⏳ Pending |

---

## Detailed Phase Breakdown

### Phase 1: Research
- [x] Analyze mobile gaming market trends (hyper-casual, hybrid-casual, arcade).
- [x] Identify high-retention mechanics and psychological drivers.
- [x] List common mistakes in modern mobile games.
- [x] Deliver: **Phase 1 Research Report** (`docs/phase_1_research.md`).

### Phase 2: Idea Generation
- [x] Brainstorm 30+ original mobile game concepts.
- [x] Filter and select the winning concept: the split/merge tether mechanic.
- [x] Deliver: **Phase 2 Ideation & Selection Document** (`docs/phase_2_ideas.md`).

### Phase 3: Validation
- [x] Answer key emotional, retention, and UX validation questions.
- [x] Deliver: **Validation Report** (`docs/phase_3_validation.md`).

### Phase 4: Game Design Document (GDD)
- [x] Detailed game systems: core loop, obstacles, Volt Crystals, ethical monetization, cosmetics.
- [x] Deliver: **Master GDD** (`docs/GDD.md`).

### Phase 5: UX/UI Prototyping
- [x] Build a working browser prototype implementing every core screen (menu, tutorial, gameplay, shop, achievements, events, settings, game over).
- [x] Deliver: **Browser prototype** (`prototype/`).

### Phase 6: Art Direction
- [x] Establish visual style (3 palettes), VFX specs, audio direction, typography.
- [x] Deliver: **Art Direction Guide** (`docs/art_direction.md`).

### Phase 7: Technology & Engine Evaluation
- [x] Compare engines (Unity, Unreal, Godot, Defold, Flutter+Flame, Phaser+Capacitor).
- [x] Deliver: **Technical Choice Decision Record** (`docs/technology_selection.md`) — **Godot 4** selected.

### Phase 8: Architecture
- [x] Design modular architecture (GameLoop, GamePlayCore, AudioSynthesizer, Renderer2D, HapticController, SaveSystem).
- [x] Deliver: **Architecture Document** (`docs/architecture.md`).

### Phase 9: Vertical Slice
- [x] Validate the core split/merge feel, spring easing tuning, and audio envelopes in the browser prototype.
- [x] Deliver: **Vertical Slice Report** (`docs/phase_9_vertical_slice.md`) + working prototype with real persistence (localStorage), background music, and a local leaderboard.

### Phase 10: Full Development — **In Progress**
- [x] Godot 4 project skeleton (`godot/`): autoloads for `GameState`/`SaveSystem`/`AudioSynth`, matching the `AppStateMachine`/`SaveSystem` roles from `docs/architecture.md`.
- [x] Port the validated core loop from the browser prototype to Godot 4 (GDScript) — `godot/scripts/gameplay.gd`.
- [x] AES-256 save encryption, via Godot's built-in `FileAccess.open_encrypted_with_pass` (`godot/autoload/SaveSystem.gd`).
- [ ] Full menu/shop/settings/achievements/events UI (still a bare stub — see `TASK_LIST.md`).
- [ ] Daily missions, real IAP/rewarded-ad SDK integration.
- [ ] Object pooling for obstacles/crystals per `OPTIMIZATIONS.md`.
- [ ] Android & iOS builds.
- [ ] First real editor test pass — the skeleton was authored by hand outside the Godot editor and hasn't been opened/run yet.

### Phase 11: QA & Optimization — **Pending**
- [ ] Rigorous testing for bugs, memory leaks, performance bottlenecks, battery drain on target devices (see `OPTIMIZATIONS.md`).
- [ ] Deliver: **QA Report & Release Build**.
