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
| 10 — Desarrollo completo (port a Godot) | Esqueleto, mecánica core, guardado AES-256, UI completa (menú/tienda/logros/config/eventos/tutorial), misiones diarias, build debug de Android. Falta IAP real, build de iOS, y confirmar renderizado en un dispositivo real | 🔧 En progreso |
| 11 — QA y lanzamiento | — | Pendiente |

## What's here

- **`docs/`** — full design process: market research, ideation, concept validation, complete Game Design Document, art direction, technology selection (Godot 4), architecture, and the vertical-slice report.
- **`project_management/`** — roadmap, task list, decisions log, risks, bugs, changelog, and optimization notes kept during design.
- **`prototype/`** — a working browser prototype (HTML/CSS/JS) implementing the full core loop: split/merge tether mechanic, Volt Crystal collection, "Grazed" combo, shop with real skin/core selection, synthesized SFX + background music, `localStorage` persistence, and a local leaderboard.
- **`godot/`** — the Phase 10 Godot 4 production port: the split/merge core loop, procedural audio, an AES-256 encrypted save file, and a full Menu / Grid Shop / Achievements / Configuration / Live Matrix Events / Tutorial UI with real daily missions. Verified running in Godot 4.7.2, including a real signed Android debug build. Real IAP/ad SDKs, an iOS build, and on-device rendering confirmation are still pending — see `project_management/TASK_LIST.md`.

## Running the prototype

Open `prototype/index.html` in a browser — no build step required.

## Running the Godot port

Open `godot/project.godot` in Godot 4.3+ and press Play. Verified working in Godot 4.7.2 as of this writing (headless script checks + an in-engine screenshot pass across every screen + an actual played run) — see `project_management/BUGS.md` for the two layout bugs that verification caught and fixed.

## Building the Android debug APK

There's no committed `export_presets.cfg` (it embeds a machine-specific keystore path, so it's gitignored like the Godot default). To rebuild it locally:

1. Install the Android SDK (via Android Studio, or the standalone `cmdline-tools`) and note its path — Godot auto-detects the common install locations.
2. Open the project in the Godot editor once, then in **Editor Settings → Export → Android**, confirm/set:
   - **Android SDK Path**: your SDK install dir.
   - **Java SDK Path**: a real JDK (17+) — a JRE without `jarsigner` won't work. Android Studio ships one at `<Android Studio install>/jbr`.
3. In **Project → Export**, add an **Android** preset. For the debug keystore, point `keystore/debug` at the standard `~/.android/debug.keystore` (user `androiddebugkey`, password `android`) — no need to generate a new one.
4. Project Settings needs `rendering/textures/vram_compression/import_etc2_astc` enabled (Android export requires it; already set in `project.godot`).
5. Export, or from the command line: `Godot --headless --path godot --export-debug "Android Debug" build/neon-tether-debug.apk`.

Verified end-to-end in this environment: the APK builds, signs (`apksigner verify` passes), installs, and its Godot engine reaches its main loop with zero crashes on an emulator (confirmed via `adb logcat`) — but that emulator's software-only GPU couldn't present a final frame to the screen (see `project_management/BUGS.md` ENV-001). That's a known limitation of software-rendered emulators, not a bug in the game; a real device or a GPU-accelerated emulator is needed to confirm on-screen rendering.

## Próximos pasos (Phase 10-11)

El port a Godot 4 (ver `docs/technology_selection.md` y `docs/architecture.md`) tiene ya el esqueleto, la mecánica core, guardado cifrado, la UI completa (menú/tienda/logros/config/eventos/tutorial) con misiones diarias reales, y un build debug de Android real y firmado. Falta: SDKs de IAP/anuncios reales, el build de iOS, y confirmar el renderizado en un dispositivo real o emulador con GPU — ver `project_management/ROADMAP.md`.

---

*Proyecto de diseño original, sin afiliación a franquicias existentes.*
