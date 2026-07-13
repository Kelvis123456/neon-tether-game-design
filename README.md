# Neon Tether

An original mobile game concept — a fast-paced, portrait rhythm-arcade physics runner where the player controls two glowing spheres linked by an elastic "tether," descending an endless vertical pipeline.

**Genre:** Rhythm-Arcade / Physics Runner · **Platform:** Mobile (Android & iOS) · **Status:** Pre-production complete (design + validated browser prototype)

## Core mechanic

Hold the screen to split the two spheres wide (avoiding center obstacles); release to snap them back together (avoiding side obstacles). Passing close to obstacles without colliding builds a "Grazed" combo. Collect Volt Crystals along the way to unlock cosmetics in the Neon Grid Shop.

## Estado del proyecto

Este repositorio es un **documento de pre-producción completo**, no un juego terminado. Cubre desde la investigación de mercado hasta la arquitectura técnica lista para implementar:

| Fase | Contenido | Estado |
|---|---|---|
| 1 — Investigación de mercado | Tendencias, oportunidades, errores comunes a evitar | ✅ |
| 2 — Ideación | 30+ conceptos generados, mecánica ganadora seleccionada | ✅ |
| 3 — Validación de concepto | Validación emocional, de retención y UX | ✅ |
| 4 — Game Design Document | Loop core, obstáculos, monetización ética, cosméticos | ✅ |
| 5 — Prototipo UX/UI | Prototipo funcional en navegador, todas las pantallas | ✅ |
| 6 — Dirección de arte | 3 paletas, specs de VFX, audio, tipografía | ✅ |
| 7 — Selección de tecnología | Godot 4 (GDScript) | ✅ |
| 8 — Arquitectura técnica | GameLoop, GamePlayCore, SaveSystem, etc. | ✅ |
| 9 — Vertical Slice | Spring easing tuneado + **prototipo jugable real** | ✅ |
| 10 — Desarrollo completo (port a Godot) | — | Pendiente |
| 11 — QA y lanzamiento | — | Pendiente |

## What's here

- **`docs/`** — full design process: market research, ideation, concept validation, complete Game Design Document, art direction, technology selection (Godot 4), architecture, and the vertical-slice report.
- **`project_management/`** — roadmap, task list, decisions log, risks, bugs, changelog, and optimization notes kept during design.
- **`prototype/`** — a working browser prototype (HTML/CSS/JS) implementing the full core loop: split/merge tether mechanic, Volt Crystal collection, "Grazed" combo, shop with real skin/core selection, synthesized SFX + background music, `localStorage` persistence, and a local leaderboard.

## Running the prototype

Open `prototype/index.html` in a browser — no build step required.

## Próximos pasos (Phase 10-11)

El port real a Godot 4 (ver `docs/technology_selection.md` y `docs/architecture.md`) para tener un build móvil instalable no ha comenzado — queda fuera del alcance de esta fase de diseño, igual que en los otros proyectos de este portfolio (PHASE, SKIM).

---

*Proyecto de diseño original, sin afiliación a franquicias existentes.*
