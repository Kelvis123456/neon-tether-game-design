# PHASE 6 REPORT: Art Direction & Visual Identity

This document defines the complete visual, acoustic, and sensory identity for **Neon Tether**, ensuring it stands out immediately in mobile storefronts.

---

## 1. Visual Identity & Art Style

### 1.1 Vector-Cyberpunk Aesthetic
The game utilizes a **Flat Neon Vector** art style. By combining simple geometric geometry with rich emissive shaders, glows, and particle trails, we create a high-end look that is both visually striking and extremely lightweight for mobile hardware.

```
Visual Hierarchy:
Foreground: White Core Stars (High-brightness emissive)
Midground: Neon Tether & obstacles (Glow-reactive vectors)
Background: Deep Obsidian & Cyber-Grid (Dark, high-contrast grid lines)
```

### 1.2 Color Systems & Palettes

We define three key thematic color maps. All interfaces and gameplay assets adjust according to the active theme.

| Theme Name | Primary Accent | Secondary Accent | Background Base |
| :--- | :--- | :--- | :--- |
| **Grid Default** | Cyan (`#00F0FF`) | Magenta (`#FF007F`) | Deep Abyss (`#040409`) |
| **Acid Storm** | Toxic Lime (`#39FF14`) | Emerald (`#00FF88`) | Dark Forest (`#050805`) |
| **Solar Eclipse** | Volcano Orange (`#FF5E00`) | Neon Gold (`#FFAA00`) | Cosmic Charcoal (`#090604`) |

---

## 2. VFX & Particle Systems

To give the game its crucial "juice," we define precise particle and trail behaviors:

* **Tether Ribbon Trails:** The two moving spheres emit a tapering ribbon trail with fading opacity (0.8 -> 0.0) over a 200ms window, visualizing velocity vector changes.
* **The Snap Flash:** When the spheres merge in the center, a quick circular white-glow shockwave expands and fades out within 150ms.
* **Shatter Spark Burst:** Upon hit, the spheres break into 24 smaller glowing particle blocks that scatter outwards with simple linear gravity pulling them down.

---

## 3. Audio & Music Specifications

The audio is designed as an interactive instrument.

### 3.1 Background Music (BGM)
* **Genre:** Synthwave / Cyberpunk (dynamic stem tracks).
* **Tempo:** Stable 130 BPM (matching obstacle spawn frequency loops).
* **Interactive Stems:**
  * *Base:* Drums and bassline play constantly.
  * *High Combo:* Synth leads and arpeggios mix in when the player maintains a combo above 2.0x.
  * *Critical state:* Low-pass filter sweeps over the music if the tether is in split state for too long.

### 3.2 Synthesized Sound Effects (SFX)
* **Split (Hold):** A pitch-ascending resonant low-pass sweep.
* **Merge Snap (Release):** A punchy snare hit layered with a chord synthesizer.
* **Graze Chime:** A sharp sine wave chime with 50ms decay.
* **Crash Shatter:** A white noise burst with a low pitch-drop envelope.

---

## 4. UI Iconography & Fonts

* **Fonts:**
  * **Outfit:** Main interface headings and buttons. Rounded geometric sans-serif that feels clean and modern.
  * **Share Tech Mono:** In-game HUD values, scores, crystal numbers, and system logs. Evokes a retro terminal vibe.
* **Iconography:** Minimalist flat white vectors (e.g., solid shapes for back buttons, geometric nodes for shop category previews, simple badges for achievements).
